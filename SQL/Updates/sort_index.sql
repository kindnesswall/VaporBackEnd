BEGIN;

-- Provinces sortIndex

-- Tehran
UPDATE public."Province" SET
"sortIndex" = '1'::bigint WHERE
id = '8';

-- Khorasan Razavi
UPDATE public."Province" SET
"sortIndex" = '2'::bigint WHERE
id = '11';

-- Isfahan
UPDATE public."Province" SET
"sortIndex" = '3'::bigint WHERE
id = '4';

-- Fars
UPDATE public."Province" SET
"sortIndex" = '4'::bigint WHERE
id = '17';

-- Khuzestan
UPDATE public."Province" SET
"sortIndex" = '5'::bigint WHERE
id = '13';

-- Cities sortIndex

-- Tehran
UPDATE public."City" SET
"sortIndex" = '1'::bigint WHERE
id = '329';

-- Mashhad
UPDATE public."City" SET
"sortIndex" = '1'::bigint WHERE
id = '491';

-- Isfahan
UPDATE public."City" SET
"sortIndex" = '1'::bigint WHERE
id = '139';

-- Shiraz
UPDATE public."City" SET
"sortIndex" = '1'::bigint WHERE
id = '727';

-- Ahvaz
UPDATE public."City" SET
"sortIndex" = '1'::bigint WHERE
id = '539';

COMMIT;
