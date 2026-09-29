"""Camera adapters for manual, source-pixel reconstruction measurements."""
import collections

import numpy as np
import pycolmap


def raw(p):
    p = np.asarray(p)
    return np.stack([p[..., 1], 719-p[..., 0]], axis=-1)


def upright(p):
    p = np.asarray(p)
    return np.stack([719-p[..., 1], p[..., 0]], axis=-1)


def project(camera, pose, points):
    assert (camera.width, camera.height) == (1280, 720)
    return upright(camera.img_from_cam(pose*points))


def triangulate(cameras, poses, observations):
    centers, directions = [], []
    for name, pixel in observations.items():
        assert (cameras[name].width, cameras[name].height) == (1280, 720)
        ray = np.r_[cameras[name].cam_from_img(raw(pixel)), 1.]
        ray = poses[name].rotation.matrix().T @ ray
        directions.append(ray/np.linalg.norm(ray))
        centers.append(poses[name].inverse().translation)
    directions = np.array(directions)
    matrices = np.eye(3)[None]-directions[:, :, None]*directions[:, None, :]
    point = np.linalg.solve(matrices.sum(0), np.einsum('nij,nj->i', matrices, centers))
    angles = np.degrees(np.arccos(np.clip(directions@directions.T, -1, 1)))
    return point, float(angles.max())


def heldout_pose(model, database, name, excluded_pixels):
    references = list(model.images.values())
    assert name not in {i.name for i in references}
    with pycolmap.Database.open(database) as db:
        query = next(i for i in db.read_all_images() if i.name == name)
        matches = collections.defaultdict(collections.Counter)
        for ref in references:
            for a, b in db.read_matches(query.image_id, ref.image_id):
                p = ref.points2D[int(b)]
                if p.has_point3D():
                    matches[int(a)][p.point3D_id] += 1
        ids = sorted(matches)
        point_ids = np.array([matches[i].most_common(1)[0][0] for i in ids])
        xy = db.read_keypoints(query.image_id)[ids, :2].astype(float)
        xyz = np.array([model.points3D[int(i)].xyz for i in point_ids])
        # Match the earlier audit: fit only odd IDs, never nearby annotated corners.
        fit = point_ids % 2 == 1
        fit &= np.min(np.linalg.norm(xy[:, None]-raw(excluded_pixels)[None], axis=2), axis=1) > 20
        ref = next(i for i in references if i.name.split('/')[0] == name.split('/')[0])
        camera = pycolmap.Camera(model.cameras[ref.camera_id].todict())
        options = pycolmap.AbsolutePoseEstimationOptions()
        options.ransac.max_error = 4.
        options.ransac.random_seed = 182
        result = pycolmap.estimate_and_refine_absolute_pose(xy[fit], xyz[fit], camera, estimation_options=options)
        assert result is not None and result['num_inliers'] >= 20
        return camera, result['cam_from_world'], int(result['num_inliers'])
