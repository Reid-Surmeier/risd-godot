# Provenance of modules/atlas

Every file below was copied unchanged (the two scripts excepted, see their headers) from
`Reid-Surmeier/qwen-pipeline-experiments`, branch `prototype/atlas-5`, commit `421f1cc`,
folder `benchmarks/atlas-prototype/godot/`, on 2026-09-13. SHA-256 is of the source file at that commit,
which for every non-script file is also the byte-identical copy here. Only the map window travelled:
the four desktop panels (`assets/desktop/`), `assets/window-title.png`, `assets/world.png` (never
loaded), the 48 plain geography tiles `{col}-{row}.png` (only the `-field` tiles are loaded), the
gitignored `*-detail.png`, the two one-node scenes (`atlas_window.tscn`, `atlas.tscn`; the nodes are
built in code here), `project.godot` and `export_presets.cfg` stayed behind.

## Where the pixels come from (records outside this repository)

| Pixels | Origin | Record |
| --- | --- | --- |
| `assets/terrain.png`, `assets/world-badges.png`, the ten regional sheets and their `-labels` / `-annotations` cuts | Muse (`meta/muse-image` via OpenRouter) generations | `qwen-pipeline-experiments` `benchmarks/world-map/pink-cyan-v001/ledger.json`, `benchmarks/regional/pink-cyan-v001/ledger.json`, `benchmarks/atlas-prototype/generation/ledger.json` (five edits, 0.05 USD) |
| `assets/geography/*-field.png` | Natural Earth 1:10m v5.1.2 (public domain) rasterised to the atlas grid | `benchmarks/atlas-prototype/reference/detail-sources.json`, `reference/sources.json` (URLs, SHA-256) |
| `close-cities.json` | GeoNames (CC BY 4.0) | `benchmarks/atlas-prototype/reference/close-cities.json.gz`, `README.md` |
| `assets/window-frame.png` | owner-supplied screenshot of a third-party game window | `benchmarks/atlas-prototype/reference/window-source.json` |
| `fonts/PixelMplus12-Regular.ttf` | PixelMplus by itouhiro, M+ FONTS licence | `fonts/LICENSE.txt` here |

Gaps carried from `docs/research/prototype-dependencies.md`: the window frame has no rights statement
beyond "owner supplied"; GeoNames CC BY asks for visible attribution in the shipped game, which the
window does not show; the Muse ledgers live in the other repository and are pointed at, not copied.

## Files

| File | Source path | SHA-256 | Note |
| --- | --- | --- | --- |
| `modules/atlas/atlas.gd` | `benchmarks/atlas-prototype/godot/atlas.gd` | `65b17c9d7b4657fe0b2cd96a99af97a5118671ce146ae1e388396605886ee7e8` | ported (edited; see the script header) |
| `modules/atlas/atlas_window.gd` | `benchmarks/atlas-prototype/godot/atlas_window.gd` | `8be8599588651a61d69af495942470a0806657cdb16e38805e8db667c37e1352` | ported (edited; see the script header) |
| `modules/atlas/geography.gdshader` | `benchmarks/atlas-prototype/godot/geography.gdshader` | `546a02bba6b186f4126019b1a5f45d6bfd25a7e442a4c8dc494fb9e9b0a221d5` | signed-distance coastline outline |
| `modules/atlas/atlas.json` | `benchmarks/atlas-prototype/godot/atlas.json` | `4126888ab07668a1582edcb37081734f28f35903b4cef683428f1782561b2150` | world size, badges, regions, control points, annotations |
| `modules/atlas/close-cities.json` | `benchmarks/atlas-prototype/godot/close-cities.json` | `0e968734017f816c0db6efe2c031d9ed5c0d0e155e63a5f99b7b4a8db21dd1ec` | 40,846 GeoNames places (CC BY 4.0) |
| `modules/atlas/fonts/PixelMplus12-Regular.ttf` | `benchmarks/atlas-prototype/godot/fonts/PixelMplus12-Regular.ttf` | `02f19467ea7cc235cc06c570b7f6c3b0a12a6f682bc8d74c43f2d323d97bcd12` | PixelMplus 12 (M+ FONTS licence) |
| `modules/atlas/fonts/LICENSE.txt` | `benchmarks/atlas-prototype/godot/fonts/LICENSE.txt` | `907e9f5ac24cba6ce2523cd2a66d6ba143e082c685344dfa8d30ef12f67410a0` | the font licence |
| `modules/atlas/assets/terrain.png` | `benchmarks/atlas-prototype/godot/assets/terrain.png` | `d3dff6079c74a067799daec5aac19ecf3ad3d20f87a3661c6664391f419fd0ac` | world terrain sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/world-badges.png` | `benchmarks/atlas-prototype/godot/assets/world-badges.png` | `ba9843b559f1fc7f5c8ff01bf4258a676549a43cbbce2124245a84c119598543` | world overview badges, Muse |
| `modules/atlas/assets/window-frame.png` | `benchmarks/atlas-prototype/godot/assets/window-frame.png` | `e95f4a55d9adf642147573b5022922e90c30b2129a5cb342c3df60881c099b2b` | the map window frame, owner-supplied (see gaps) |
| `modules/atlas/assets/europe.png` | `benchmarks/atlas-prototype/godot/assets/europe.png` | `9705d50cfde60604b53d354e7d6471b92d201e8b25201ce7e891ce9cb1067aef` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/europe-labels.png` | `benchmarks/atlas-prototype/godot/assets/europe-labels.png` | `e9e05621b4c4d9c84ed35a23715be5560a964a55186b18634e726f41de9839a5` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/europe-annotations.png` | `benchmarks/atlas-prototype/godot/assets/europe-annotations.png` | `ba9fb72b7271e59922cb315e722404b6ab5ae85ae55d71fecdccb30a5e182dea` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/africa.png` | `benchmarks/atlas-prototype/godot/assets/africa.png` | `acb399d272aaf0c8a9d1b1d2f95d2867a26e7837d99ec57f0dcdd3802294e67e` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/africa-labels.png` | `benchmarks/atlas-prototype/godot/assets/africa-labels.png` | `34479bf15921b794d407de14dd4cdcd20186bf9d33ad6988ec90893a0f64dfc5` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/africa-annotations.png` | `benchmarks/atlas-prototype/godot/assets/africa-annotations.png` | `c70a366273ec4d4666b10c5806d8579555ded5645e93f92a257670a6a000f88e` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/asia.png` | `benchmarks/atlas-prototype/godot/assets/asia.png` | `b23f5eaa84829db0107babd0614fe7f603edb36d8e50a225064c5693de942e7b` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/asia-labels.png` | `benchmarks/atlas-prototype/godot/assets/asia-labels.png` | `dfb92f53502d3115f1937ce770b240e04aeef3742125ef70efa5b69e62e1fdc3` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/asia-annotations.png` | `benchmarks/atlas-prototype/godot/assets/asia-annotations.png` | `df6dd0fb40e6492afcfe20c5f821967de357bd44900c2e74a6407664cf39d3c2` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/australia.png` | `benchmarks/atlas-prototype/godot/assets/australia.png` | `dc1a9d8710bb67f9bc0ad7f653bbdc4a9e2505b3a5bfcde78f70770abd018df5` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/australia-labels.png` | `benchmarks/atlas-prototype/godot/assets/australia-labels.png` | `09aeeefa7bc47438801322e690df94373ad59b248eef56b67cffbbd1ff0fe648` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/australia-annotations.png` | `benchmarks/atlas-prototype/godot/assets/australia-annotations.png` | `385df74fbd660abd99fc3e34d5a944e7670d840cf0d2dfc1eb796792e3ce9bc9` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/canada.png` | `benchmarks/atlas-prototype/godot/assets/canada.png` | `fd654ac03882997b7b61cc5b92271313a8d58d2871e1c6106420857ce043726c` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/canada-labels.png` | `benchmarks/atlas-prototype/godot/assets/canada-labels.png` | `c4d303f8dfa2d1132850323fa02c694c3b0d01df0a9fbc3e385709160c553cff` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/canada-annotations.png` | `benchmarks/atlas-prototype/godot/assets/canada-annotations.png` | `ffa67014dd7a2a09e9c1f7bd42cad6eb9e0cbe09de80997d6a355fded0cfce1f` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/caribbean.png` | `benchmarks/atlas-prototype/godot/assets/caribbean.png` | `88f26e039542c9a9f91cfe6f94290b171e351bc124a6765b085ca4a3c7dd0f23` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/caribbean-labels.png` | `benchmarks/atlas-prototype/godot/assets/caribbean-labels.png` | `cc8183312fd7a082fb66431f87a1a6af12bb6833983425e4e5c56ae95775a4ab` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/caribbean-annotations.png` | `benchmarks/atlas-prototype/godot/assets/caribbean-annotations.png` | `0132d72f4eaf049e06197c3816fb6514e2d133c48f79c1e933870b58c3141222` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/russia.png` | `benchmarks/atlas-prototype/godot/assets/russia.png` | `307361e4b526c36cc4a5255d7190a1b6bdcd1f8bd3932c220128cd2486e50843` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/russia-labels.png` | `benchmarks/atlas-prototype/godot/assets/russia-labels.png` | `48360f60f22ec4330106f235fe70c61ab9cc005a28d3e1872a35b68c3c667121` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/russia-annotations.png` | `benchmarks/atlas-prototype/godot/assets/russia-annotations.png` | `537c53e3372b458fb20edbc86413060d7e107ec29a35b6d12da9976fd08af01e` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/south-america.png` | `benchmarks/atlas-prototype/godot/assets/south-america.png` | `1620ffc1243489e8d45d670c413355d0344d997608cda47307915494f24449a3` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/south-america-labels.png` | `benchmarks/atlas-prototype/godot/assets/south-america-labels.png` | `a246dba8b7b54d5bd0b05b20782729907903047378a29431d109a93e8eec9532` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/south-america-annotations.png` | `benchmarks/atlas-prototype/godot/assets/south-america-annotations.png` | `333d5482fdaa7f95c4ec3015f4aae64188ca90e7ec8f0c925b1ae05059eb3540` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/usa.png` | `benchmarks/atlas-prototype/godot/assets/usa.png` | `4ec2967f1a0f46609c56fb49fa7c125ead3a21c4c028b74144488732a26d4727` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/usa-labels.png` | `benchmarks/atlas-prototype/godot/assets/usa-labels.png` | `0fe057299837c720aceb37a3e195ff46e17e148cca403bee33b618022d1138a7` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/usa-annotations.png` | `benchmarks/atlas-prototype/godot/assets/usa-annotations.png` | `ddfebd5f1390a7c0cd363085b1a32fd47c4375da55d29a6dc6fb999bc0ef79d1` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/middle-east.png` | `benchmarks/atlas-prototype/godot/assets/middle-east.png` | `657869e51085187c620b16da32a029554dc15e3f71fbec9ac198daeab0819ed3` | regional sheet, Muse (pink-cyan-v001) |
| `modules/atlas/assets/middle-east-labels.png` | `benchmarks/atlas-prototype/godot/assets/middle-east-labels.png` | `fb2e3df4b038b747f580901b79440eaeb4067ccb6d82d8564ca271212e74f518` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/middle-east-annotations.png` | `benchmarks/atlas-prototype/godot/assets/middle-east-annotations.png` | `24b33b8ce46319c917f1c3db6fec7159022987408b7c2d5c33e495f70b078c88` | Muse-drawn labels / badges cut for the region sheet |
| `modules/atlas/assets/geography/0-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-0-field.png` | `f9364db17d1f1a93a332441ec61fdd95dcf2be4627318dda532b0077f767eee3` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/0-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-1-field.png` | `b949265979394127c1058a2f2cbaf80caa0bfc6ad0ea220cf22e5cf0e721dc73` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/0-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-2-field.png` | `84b00b01fe5e4b6fa4d65e87f53367538103926b3a768280aa368211d22c99b0` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/0-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-3-field.png` | `f8a16d148228b5f164775c1ad3929254d7404b89e69d553ed45d48ed69ec9cec` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/0-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-4-field.png` | `2593c74d3e461a7070c5835aea2445dc3fbd852ed5f395be2f4aab6d6799675a` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/0-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/0-5-field.png` | `4355d5ea33c2dce2452980badb0bbfc25cb9eabd22961785121720b3f1903fda` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-0-field.png` | `a3e10b015b70f986bfcbb4f1c6c4efc655b63da3f0d32d9befb2f9cad0480746` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-1-field.png` | `7bfcd91f695c9169995a5246038e39fa0fbea2f9900d1794d25ebbe426eb8ffc` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-2-field.png` | `d9f37e119f7e35a6c8e5e7bd48134a5dc22ed0c4d419656ce6338dbf487b147f` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-3-field.png` | `6a28a569e554560c0a034163035a54d12cfe621f9758c86bc809743a8ecd42f2` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-4-field.png` | `8ba3eb74a485a69f26f5391ce3fa04a8df5cd3af0bed87c70a88a53d8209a78f` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/1-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/1-5-field.png` | `6e5f10f8befa0fc40c0f261d194c033f247f4f2783a3280b11ea100481ad75c9` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-0-field.png` | `a9e42a13f08038f3ab634f1e4f4173ef2c576893d495005f45639be0f33b91a8` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-1-field.png` | `1399d8ee39f8d4ab82c5ffafcf28ec96879c474a1e45587738da76fced26853d` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-2-field.png` | `cde59fed9353f0dc4ecf0a39f39ddc981c4e12d0a73e43a77175809914f3c6d2` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-3-field.png` | `687d2f581d6150303f115963093427fd2b5eae96bffcfc24f1473d4442657a62` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-4-field.png` | `f77d6bdaa302594705fbb7d9b84d1223cf2e171f8a758fedb6840e05180f7ae9` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/2-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/2-5-field.png` | `0c140b80e1a958fb5ca0f301256a9759194bf066913770ccd302e063b11dde7a` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-0-field.png` | `1eca24a0f4c7f92726de0e46c6fe424f7ef5be27aa462f97c647ff3d113bc5b5` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-1-field.png` | `085a392c8012a30aadd429d22d4cba3292e3798715b278c70e1754126fecf0ee` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-2-field.png` | `d8944d95f4e7ee438e1de73992cc7a113130b5443db3139804ba073d6d95cfe4` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-3-field.png` | `cb59adafe3aca413d2393adaadbbc75374fbc87ab422971c1df733bf8fd42566` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-4-field.png` | `e31a82df4842c22a86ef27cefd5a70157d85060b8d232c472187a06b03ed0c33` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/3-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/3-5-field.png` | `394be2f12a00245a2384cb275c9ff926e315badbc40c4f9bccff17d0037044df` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-0-field.png` | `4edc7dc5ad835f6fffbb69b764a51f362caf31437c477398c3aa84816a8b445a` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-1-field.png` | `1c53ef3c08d32233949a3fea399ce827aed5637224b105919ecdca941ad467f4` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-2-field.png` | `8aca3f7b8e66a781112b7cd3cb7e2600f23a8d0abbde3258b793b31b3992a6d4` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-3-field.png` | `5f64083056433b5e4b746cb223fc0303ccaf0aafffb6d33935e1c8c71b32895f` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-4-field.png` | `eb681568b27ce75f16c44055ef2d78eff5c216a8d3aca4dceb8bf1ccf776d782` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/4-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/4-5-field.png` | `95ab9d707f62445062c82f91d68fb70db303bdc7f92c3f1f7de2d5610d43e68e` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-0-field.png` | `572a8161de70f257d46d35de4bb1dd380417fc7fe93f32ca85227eafad15ac3a` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-1-field.png` | `08858bbde8afee3c15616a1d575f0f73c97e54c9087cf81249bd5f42c8a8ec22` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-2-field.png` | `fe156b57ce23c6be43770957baf33d5ccdd55bde6d50f48dd9a02f2cb7d380fc` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-3-field.png` | `1c30c3a8655ba8938ba60567c77931386f1bc044650bdd719e88e7cc3e65a2c0` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-4-field.png` | `a8db1fb4b3e245ed3d52181c06a12b5571264296741733a747c244c84b5bfac6` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/5-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/5-5-field.png` | `2931edeea43b3f5da28de50f326a8a3a733d2b567885e6d56dcd41610a7b9abb` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-0-field.png` | `6d544c6c7c7a0ac476e5f816c3e6d02dafaa7e7617c5a40c792d69f51ac32e49` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-1-field.png` | `d2a17ea4fb26e31387a452e1a5cf1d8d6ac34b383ac9c989b2b8e7284d2bdbde` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-2-field.png` | `1ad097d3d1d32196e6a9ad8cbbc84c09b346c48a7c11911adc88c6fd9417affd` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-3-field.png` | `a45adbc082aea8313511b3330100d2dbfe37738da727cad7dd9908b6cdaddffd` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-4-field.png` | `87ea509833a82d5992ac84054f1025ead44404b04ec1c86535484f15a0047bf2` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/6-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/6-5-field.png` | `95ab9d707f62445062c82f91d68fb70db303bdc7f92c3f1f7de2d5610d43e68e` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-0-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-0-field.png` | `c854e1acc10760c2e226e75bb8200b029cfbb201646e69b0fe64472c23dcacf8` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-1-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-1-field.png` | `abec380be0f1ee374f05382c26f8b0e35f7c961f9b86ce6dd8511b9167a17c57` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-2-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-2-field.png` | `199a023dfb0296ab8b9037056c55c5fc26e4ba95598b63c3595f2c47472a1c20` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-3-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-3-field.png` | `69bc16921eec6adfd1550d0b2345b0d932cce9d1e75b3b7a7f0c71a38aab54c1` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-4-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-4-field.png` | `db5f407a0813d99c46451bc2c947c834125115db0c17b795172c139fed4dd810` | coastline field tile, Natural Earth 1:10m v5.1.2 |
| `modules/atlas/assets/geography/7-5-field.png` | `benchmarks/atlas-prototype/godot/assets/geography/7-5-field.png` | `650db3990c9b617935b5dd2c3c55fa74f352336055bdb8d868a1b33406b91c15` | coastline field tile, Natural Earth 1:10m v5.1.2 |

88 files.
