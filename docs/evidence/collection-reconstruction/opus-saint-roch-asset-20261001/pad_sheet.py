"""Edge-pad the Muse sheet so a mesh edge that falls just outside a painted silhouette reads wood, not the grey ground.
Every ground pixel (and the four caption words) takes the colour of the nearest sculpture pixel. Sculpture pixels are
copied unchanged and nothing is drawn. Usage: python3 pad_sheet.py <muse sheet> <padded lossless webp>"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

rgb = np.asarray(Image.open(sys.argv[1]).convert("RGB"))
ground = np.median(rgb[:60].reshape(-1, 3), axis=0)
painted = ndimage.binary_opening(np.abs(rgb.astype(int) - ground).sum(2) > 40, iterations=2)
labels, _ = ndimage.label(painted)
sizes = np.bincount(labels.ravel())
keep = np.isin(labels, [k for k in range(1, len(sizes)) if sizes[k] > 30000])  # the four figures, not the captions
keep = ndimage.binary_erosion(ndimage.binary_fill_holes(keep), iterations=2)  # drop the blended outline pixels
nearest = ndimage.distance_transform_edt(~keep, return_distances=False, return_indices=True)
padded = rgb[nearest[0], nearest[1]]
assert (padded[keep] == rgb[keep]).all()
Image.fromarray(padded).save(sys.argv[2], lossless=True)
print("figures", int((sizes > 30000).sum()) - 1, "kept px", int(keep.sum()), "of", keep.size)
