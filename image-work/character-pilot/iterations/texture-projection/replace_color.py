"""Texture-only GLB edit; original BIN prefix and geometry/rig/clip JSON unchanged.
python3 replace_color.py input.glb color.png output.glb
"""
import copy, json, struct, sys
from pathlib import Path

def replace_color(source, png, output):
    raw=Path(source).read_bytes();image=Path(png).read_bytes()
    assert raw[:4]==b'glTF' and image[:8]==b'\x89PNG\r\n\x1a\n'
    size=struct.unpack_from('<I',raw,12)[0]
    original=json.loads(raw[20:20+size]);data=copy.deepcopy(original)
    offset=20+size;count=struct.unpack_from('<I',raw,offset)[0]
    binary=raw[offset+8:offset+8+count]
    original_binary=binary
    # This study has exactly one base-color texture shared by its body material.
    targets={data['textures'][m['pbrMetallicRoughness']['baseColorTexture']['index']]['source']
             for m in data['materials'] if 'baseColorTexture' in m.get('pbrMetallicRoughness',{})}
    assert len(targets)==1, 'Expected one shared base-color image'
    target=targets.pop()
    assert 'bufferView' in data['images'][target], 'Expected embedded PNG source'
    data['bufferViews'].append({'buffer':0,'byteOffset':len(binary),'byteLength':len(image)})
    data['images'][target]['bufferView']=len(data['bufferViews'])-1
    data['images'][target]['mimeType']='image/png'
    binary+=image;binary+=b'\x00'*((-len(binary))%4)
    data['buffers'][0]['byteLength']=len(binary)
    document=json.dumps(data,separators=(',',':')).encode();document+=b' '*((-len(document))%4)
    assert binary[:len(original_binary)]==original_binary
    for key in ['meshes','accessors','skins','nodes','animations','materials','textures']:
        assert data.get(key)==original.get(key),key
    result=struct.pack('<4sII',b'glTF',2,28+len(document)+len(binary))
    result+=struct.pack('<I4s',len(document),b'JSON')+document
    result+=struct.pack('<I4s',len(binary),b'BIN\x00')+binary
    assert Path(source).resolve()!=Path(output).resolve(), 'Keep the source'
    Path(output).write_bytes(result)
    assert Path(source).read_bytes()==raw
    print(json.dumps({'success':True,'source_unchanged':True,'original_bin_prefix_identical':True,
                      'geometry_uv_rig_actions_json_identical':True,'color_image_index':target,
                      'png_dimensions':struct.unpack_from('>II',image,16),'output':str(output)}))

if __name__=='__main__':
    assert len(sys.argv)==4, __doc__
    replace_color(*sys.argv[1:])
