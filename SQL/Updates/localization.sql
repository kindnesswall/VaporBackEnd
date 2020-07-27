
BEGIN;

-- Iran
UPDATE public."Country" SET
localization = 'fa'::text WHERE
id = '103';

COMMIT;
