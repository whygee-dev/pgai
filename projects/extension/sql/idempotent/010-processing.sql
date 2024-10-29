
-------------------------------------------------------------------------------
-- processing_default
create or replace function ai.processing_default
( batch_size int default null
, concurrency int default null
) returns jsonb
as $func$
    select json_object
    ( 'implementation': 'default'
    , 'config_type': 'processing'
    , 'batch_size': batch_size
    , 'concurrency': concurrency
    absent on null
    )
$func$ language sql immutable security invoker
set search_path to pg_catalog, pg_temp
;

-------------------------------------------------------------------------------
-- _validate_processing
create or replace function ai._validate_processing(config jsonb) returns void
as $func$
declare
    _config_type text;
    _implementation text;
    _val jsonb;
begin
    if pg_catalog.jsonb_typeof(config) != 'object' then
        raise exception 'processing config is not a jsonb object';
    end if;

    _config_type = config operator ( pg_catalog.->> ) 'config_type';
    if _config_type is null or _config_type != 'processing' then
        raise exception 'invalid config_type for processing config';
    end if;
    _implementation = config operator(pg_catalog.->>) 'implementation';
    case _implementation
        when 'default' then
            _val = pg_catalog.jsonb_extract_path(config, 'batch_size');
            if _val is not null then
                if pg_catalog.jsonb_typeof(_val) operator(pg_catalog.!=) 'number' then
                    raise exception 'batch_size must be a number';
                end if;
                if cast(_val as int) > 2048 then
                    raise exception 'batch_size must be less than or equal to 2048';
                end if;
                if cast(_val as int) < 1 then
                    raise exception 'batch_size must be greater than 0';
                end if;
            end if;

            _val = pg_catalog.jsonb_extract_path(config, 'concurrency');
            if _val is not null then
                if pg_catalog.jsonb_typeof(_val) operator(pg_catalog.!=) 'number' then
                    raise exception 'concurrency must be a number';
                end if;
                if cast(_val as int) > 50 then
                    raise exception 'concurrency must be less than or equal to 50';
                end if;
                if cast(_val as int) < 1 then
                    raise exception 'concurrency must be greater than 0';
                end if;
            end if;
        else
            if _implementation is null then
                raise exception 'processing implementation not specified';
            else
                raise exception 'unrecognized processing implementation: "%"', _implementation;
            end if;
    end case;
end
$func$ language plpgsql immutable security invoker
set search_path to pg_catalog, pg_temp
;
