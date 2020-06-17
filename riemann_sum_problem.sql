-- Evil is present here
-- ████████╗██╗  ██╗██╗███████╗    ██╗███████╗    ███████╗██╗   ██╗██╗██╗
-- ╚══██╔══╝██║  ██║██║██╔════╝    ██║██╔════╝    ██╔════╝██║   ██║██║██║
--    ██║   ███████║██║███████╗    ██║███████╗    █████╗  ██║   ██║██║██║
--    ██║   ██╔══██║██║╚════██║    ██║╚════██║    ██╔══╝  ╚██╗ ██╔╝██║██║
--    ██║   ██║  ██║██║███████║    ██║███████║    ███████╗ ╚████╔╝ ██║███████╗
--    ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝    ╚═╝╚══════╝    ╚══════╝  ╚═══╝  ╚═╝╚══════╝

--
-- ██████╗ ██╗     ███████╗ █████╗ ███████╗███████╗    ██████╗  ██████╗ ███╗   ██╗████████╗    ██████╗  ██████╗     ████████╗██╗  ██╗██╗███████╗
-- ██╔══██╗██║     ██╔════╝██╔══██╗██╔════╝██╔════╝    ██╔══██╗██╔═══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██╔═══██╗    ╚══██╔══╝██║  ██║██║██╔════╝
-- ██████╔╝██║     █████╗  ███████║███████╗█████╗      ██║  ██║██║   ██║██╔██╗ ██║   ██║       ██║  ██║██║   ██║       ██║   ███████║██║███████╗
-- ██╔═══╝ ██║     ██╔══╝  ██╔══██║╚════██║██╔══╝      ██║  ██║██║   ██║██║╚██╗██║   ██║       ██║  ██║██║   ██║       ██║   ██╔══██║██║╚════██║
-- ██║     ███████╗███████╗██║  ██║███████║███████╗    ██████╔╝╚██████╔╝██║ ╚████║   ██║       ██████╔╝╚██████╔╝       ██║   ██║  ██║██║███████║
-- ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝       ╚═════╝  ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝

drop table rect_partial_values;
create table rect_partial_values(
    partial number not null,
    rank number not null
);
drop table rect_results;
create table rect_results(
    ts timestamp,
    result number
);

drop table rect_params;
create table rect_params(
    num_threads integer not null,
    p_start float not null,
    p_end float not null,
    n_steps integer not null
);
insert into rect_params values (10,0,10,8388600);


commit;



create or replace trigger rect_completed
    after insert on rect_partial_values
--for each row
declare
    num_threads integer;
    cnt integer;
    total number;
begin
    select num_threads into num_threads from rect_params fetch first 1 row only;
    select count(*) into cnt from rect_partial_values;

    if cnt >= num_threads then
        select sum(partial) into total from rect_partial_values;
        insert into rect_results values(CURRENT_TIMESTAMP, total);
        delete from rect_partial_values;
    end if;
    --commit;
end;


create or replace procedure partial_rect(rank in number, num_threads in integer, p_start in number, p_end in number, n_steps in number) as
        local_sum float;
        h float;
        start_i integer;
        end_i integer;
        chunk_size integer;
        f_result float;
        p_current float;
begin
    h := (p_end - p_start) / n_steps;
    local_sum := 0;
    chunk_size := n_steps / num_threads;

    start_i :=rank * chunk_size;
    end_i := (rank+1) * chunk_size;

    if (rank = num_threads-1) then
        end_i := n_steps;
    end if;

    for i in start_i..(end_i-1) loop
        p_current := i * h;
        f_result := cos(p_current);
        local_sum := local_sum + (f_result*h);
    end loop;

    insert into rect_partial_values values(local_sum, rank);
    commit;

end;


create or replace procedure run_rect as
    useless binary_integer;
    num_threads integer;
        p_start float;
    p_end float;
    n_steps integer;
begin

    select num_threads into num_threads from rect_params fetch first 1 row only;
    select p_start into p_start from rect_params fetch first 1 row only;
    select p_end into p_end from rect_params fetch first 1 row only;
    select n_steps into n_steps from rect_params fetch first 1 row only;

    insert into rect_results values(CURRENT_TIMESTAMP, null);
    for i in 0..(num_threads-1) loop
        --dbms_output.PUT_LINE('partial_rect(' ||i||','|| num_threads ||','||p_start||','||p_end||','||n_steps||');');
        --partial_rect(i,num_threads,p_start,p_end,n_steps);
        dbms_job.submit(useless, 'partial_rect(' ||i||','|| num_threads ||','||p_start||','||p_end||','||n_steps||');');
    end loop;
    commit;

end;


create or replace procedure calc_runtime is
    --ans number;
    endtime timestamp;
    starttime timestamp;
    testcompletion float;
begin
   -- ans := sin(10);
    select ts into endtime from rect_results order by ts desc fetch first 1 row only;
    select ts into starttime from rect_results order by ts desc offset 1 row fetch  next 1 row only;
   select result into testcompletion from rect_results order by ts desc fetch first 1 row only;
   if testcompletion is not null then
       select result into testcompletion from rect_results order by ts desc offset 1 row fetch  next 1 row only;
       if testcompletion is null then
           dbms_output.PUT_LINE('Runtime is ' || to_char(endtime-starttime));
           return;
       end if;
   end if;
    dbms_output.PUT_LINE('Runtime cannot be calculated yet');
    commit;
end;


-- this will actually call our functions to run the algorithm.
call run_rect();

-- if you run this immediately, while the DBMS is still running the algorithm, this will print out an error.
-- wait a 
call calc_runtime();
