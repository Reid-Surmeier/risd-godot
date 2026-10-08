# Spend on #263

Flora charges are the `charged_cost` each run reported. Updated as runs finish.

| Date | Workspace | Object | Model, settings | Quote | Charged |
| --- | --- | --- | --- | --- | --- |
| 7 Oct | OpenRouter | fireplace 83.152 | Muse isolate | 0.01 ceiling | refused (HTTP 400); not confirmed |
| 7 Oct | personal | fireplace 83.152 | Trellis, simplify 0.98 | 0.024 | 0.024 |
| 7 Oct | personal | Neptune 2017.74.31.1 | Trellis, simplify 0.98 | 0.024 | 0.024 |
| 7 Oct | personal | fireplace 83.152 | Trellis, simplify 0.90, texture 2048 | 0.024 | 0.024 |
| 7 Oct | personal | Neptune 2017.74.31.1 | Trellis, simplify 0.90 | 0.024 | 0.024 |
| 8 Oct | RISD EDU | fireplace 83.152 | Tripo H3.1, detailed geometry and texture, 20k faces | 0.72 | 0.72 |
| 8 Oct | RISD EDU | Neptune 2017.74.31.1 | Tripo H3.1, detailed geometry, 12k faces | 0.60 | 0.60 |
| 8 Oct | RISD EDU | Amphitrite 2017.74.31.2 | Tripo H3.1, 8k faces | 0.36 | 0 (refused: content policy) |
| 8 Oct | RISD EDU | Crucified Christ 43.195 | Tripo H3.1, detailed geometry, 12k faces | 0.60 | 0.60 |
| 8 Oct | RISD EDU | Head of Christ 59.131 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| 8 Oct | RISD EDU | Amphitrite 2017.74.31.2 | Trellis, simplify 0.98 | 0.024 | 0.024 |
| 8 Oct | RISD EDU | Angel of the Annunciation 37.114 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| 8 Oct | RISD EDU | Saint Peter 20.254 | Tripo H3.1, 10k faces | 0.36 | 0.36 |

**Charged so far: 3.12 USD** (personal 0.096, RISD EDU 3.024). Still in Flora's queue when the batch was stopped, 0.36 quoted each: Christ in Majesty 69.196, Hand of God 23.005, Apostles 41.045 and 41.046, River God 44.674, Récamier 37.201, Tabernacle 06.057.

## After the stop (8 October)

Stopped-route runs that were already queued; downloaded outside git (`~/risd-godot-ingestion/mesh-pilot-263/rejected-route/`), not built:

| Object | Model | Quote | Charged |
| --- | --- | --- | --- |
| Christ in Majesty 69.196 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| Hand of God 23.005 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| River God 44.674 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| Apostle 41.045 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| Apostle 41.046 | Tripo H3.1, 10k faces | 0.36 | 0.36 |
| Récamier 37.201 | Tripo H3.1, 10k faces | 0.36 | 0.36 (finished; left on Flora, not downloaded) |
| Tabernacle 06.057 | Tripo H3.1, 10k faces | 0.36 | 0.36 (finished; left on Flora, not downloaded) |

Saint Peter 20.254 on the Muse-first route (owner's go for one object):

| Call | Quote | Charged |
| --- | --- | --- |
| Muse, 4 clay views (OpenRouter, `meta/muse-image`) | 0.04 | 0.04 (reported cost 0.01 each) |
| Muse, 4 colour views | 0.04 | 0.04 |
| Muse, 3 matched clay views | 0.03 | 0.03 |
| Tripo H3.1 Multi-View, geometry detailed, no texture, 20,000 faces (RISD EDU) | 0.48 | 0.48 |
| Tripo H3.1 Multi-View, geometry detailed, no texture, 500,000 faces (RISD EDU) | 0.48 | 0.48 |

| Meshy 5 Retexture on variant B (RISD EDU) | 0.36 | 0.36 |

| Muse, 5 flat colour views (one retry) | 0.05 | 0.05 |

**Charged so far: 7.12 USD**: 3.12 above, 2.52 stopped-route, 1.48 Saint Peter Muse-first (0.16 Muse, 0.96 Tripo, 0.36 Meshy retexture).

## Batch on the Muse-first route (owner's go, 8 October)

| Object | Muse images | Tripo H3.1 Multi-View (RISD EDU), quote / charged | Result |
| --- | --- | --- | --- |
| Angel of the Annunciation 37.114 | 8 (0.08) | 0.48 / 0.48 | accepted, 391 KB |
| Head of Christ 59.131 | 6 (0.06) | 0.48 / 0.48 | accepted, 467 KB |
| Bust of Madame Récamier 37.201 | 6 (0.06) | 0.48 / 0.48 | rejected: invented round socle, invented veining and dark hair in the colour |

| The Hand of God 23.005 | 11 (0.11); one more failed with HTTP 502, not resubmitted, charge unknown | 0.48 / 0.48 | form right, colour streaked at the edges; 303 KB; not placed |

Head of Christ rebuilt at 512 px colour: 303 KB (was 467 KB), no charge.

| The Crucified Christ 43.195 | 4 (0.04) | 0.48 / 0.48 | accepted, 478 KB (1024 px colour: a 2.16 m piece) |

The Hand of God redone as plain marble (no charge): accepted, 233 KB.

| Object | Muse images | Tripo H3.1 (RISD EDU), quote / charged | Result |
| --- | --- | --- | --- |
| Apostle 41.045 | 3 (0.03) | Multi-View 0.48 / 0.48 | accepted as a relief, 256 KB |
| Apostle 41.046 | 3 (0.03) | Multi-View 0.48 / 0.48 | accepted as a relief, 278 KB |
| Christ in Majesty 69.196 | 3 (0.03) | Multi-View 0.48 / 0.48, rejected: the invented side view gave a second arm and a 0.46 m block | not kept |
| Christ in Majesty 69.196, redo | none | single view from the clay front alone, 0.48 / 0.48 | accepted, 271 KB with the occlusion at 0.5; placed in the room source |

| Tabernacle 06.057 | 2 (0.02) | single view from the clay front alone, 0.48 / 0.48 | 258 KB; geometry accepted; recoloured warm (ivory base, shading towards the photograph's own shadow colour); placed in the room source |

| Pietà 59.128 | 5 (0.05): clay front, a three-quarter and a carved back that were not used, a strict left profile, flat front | Multi-View from front + left, 0.48 / 0.48 | 252 KB; placed in the room source |
| Saint Roch 21.398 | 6 (0.06): clay front, back and left, flat front and back, and a flat left that repeated the front and was not used | Multi-View from front, left, back, 0.48 / 0.48 | 262 KB; placed in the room source |

| Bust of Madame Récamier 37.201, redo | 3 (0.03): clay front, right and back; a fourth call (clay left) failed with HTTP 502, was not resubmitted, charge unknown and not counted | Multi-View from back, right, front (the frame turned half round), 0.48 / 0.48 | 256 KB; geometry accepted; recoloured honey (mid-tone base, amber shading); placed in the Rockefeller room source |
| Fireplace surround 83.152 | 3 (0.03): clay front (Muse accepted it this time), clay left, flat front | Multi-View from front + left, 0.48 / 0.48 | 358 KB at 1024 px colour; placed in the room source |
| River God 44.674 | 0: the one clay attempt was refused (HTTP 400), charge unknown and not counted | Multi-View from the museum's own front, left and back photographs, 0.48 / 0.48 | 224 KB; kept as a trial only, not in the game sources: the lead withdrew the photograph route on 8 October (a refused Muse step is a stop) and put it to the owner as item 20 on #262 |

| Neptune 2017.74.31.1 | 0 | Multi-View from the museum's own photographs, 0.48 / 0.48 | a trial only: submitted minutes before the lead's stop on the photograph route reached me; built afterwards at no cost for its sheet; 260 KB; not in the game sources |
| Amphitrite 2017.74.31.2 | 0 | the same, quoted 0.48, charged 0 | the run failed (the provider was overloaded); not resubmitted; she stays as she is |

| Panel with Striding Lion 34.652 | 2 (0.02): clay front (accepted by Muse), flat front | single view from the clay front alone, 0.48 / 0.48 | 360 KB at 1024 px colour; sheet made; not placed yet |

| St. George and the Dragon 2017.74.14 | 10 (0.10): clay front, back, right; three flat views wasted on my own wrong colour description (a white horse) and a repeated view; flat front and back redone, mauve; redone once more, chestnut, as the photograph has it | Multi-View from back, right, front (the frame turned half round), 0.48 / 0.48 | 276 KB; placed in the Rockefeller room source |

**Batch so far: 9.39 USD** (75 Muse images 0.75, fifteen Multi-View meshes 7.20, three single-view meshes 1.44). **Whole effort: 16.51 USD charged.**

Not counted, because the charge is unknown: three Muse calls that failed and were not resubmitted (Hand of God flat back HTTP 502, Récamier clay left HTTP 502, River God clay front HTTP 400) and the pilot's fireplace call (HTTP 400). At 0.01 USD each the most they can add is 0.04 USD.
