BEGIN;

-- Cities hasRegions

-- Tehran
UPDATE public."City" SET
"hasRegions" = true::boolean WHERE
id = '329';

-- Mashhad
UPDATE public."City" SET
"hasRegions" = true::boolean WHERE
id = '491';

-- Isfahan
UPDATE public."City" SET
"hasRegions" = true::boolean WHERE
id = '139';

-- Shiraz
UPDATE public."City" SET
"hasRegions" = true::boolean WHERE
id = '727';

-- Tabriz
UPDATE public."City" SET
"hasRegions" = true::boolean WHERE
id = '14';

COMMIT;
