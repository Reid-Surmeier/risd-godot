# Mechanical matte removal; creative pixels come from the recorded Muse donor.
from PIL import Image
import numpy as np
from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=Image.open(root/'image-work/frame-donor.webp').convert('RGB')
a=np.asarray(source).astype(float);dominance=a[:,:,1]-np.maximum(a[:,:,0],a[:,:,2])
alpha=np.clip(1-(dominance-20)/50,0,1)*255
rgba=np.dstack((a,alpha)).astype('uint8')
Image.fromarray(rgba).save(root/'assets/glove-frame.png')
assert rgba[0,0,3]==0 and rgba[source.height//2,source.width//2,3]==0
assert np.count_nonzero(rgba[:,:,3]==255)>source.width*source.height*.15
print({'size':source.size,'transparent_pixels':int(np.count_nonzero(rgba[:,:,3]==0))})
