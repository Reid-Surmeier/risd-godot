# Portal preview loading correction

Owner reported the default engine loader on the portal preview. The Doorway Prototype export now selects the existing shared loading shell, with a metadata flag for its single-pack startup. The full application's boot-pack path is unchanged. No duplicated animation source.

Shared HTTPS browser check passed: custom shader/overlay present, progress advances, overlay exits, portal visible, zero page errors. `loading.png` captures the colored dots during their exit fade; `loaded.png` is the unobstructed portal. Export and diff whitespace check pass. This corrects preview presentation; the architecture's final independent review remains incomplete.
