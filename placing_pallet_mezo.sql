/*with item as (select distinct
                            ai.sourcekey as item_id
                            --ain.ItemTagId
                            ,listagg(distinct ain.Name) as TagName
                            ,listagg(distinct ain.ItemTagId) as TagIDs
                            --,kio.ItemTagOwner
                    from dwh_data.tie_item_itemtag tii
                             join dwh_data.anc_item ai using (itemid)
                             join dwh_data.atr_itemtag_name ain using (itemtagid)
                             join dwh_data.atr_itemtag_owner aio using (itemtagid)
                             join dwh_data.knot_itemtagowner kio
                                  on kio.itemtagownerid = aio.ownerid and kio.ItemTagOwner in ( 'wms' , 'AMS')
       where ain.ItemTagId in (
                           9155987984438942942 -- 'Закрытая зона'
           , 4277141987851467413 -- '1 класс опасности'
           , 5091327832147112866 -- '2 класс опасности'
           , 8689657220703050304 -- '3 класс опасности'
           , 6082072584947048150 -- '4 класс опасности'
           , 8021102035680062104 -- '5 класс опасности'
           , 9151922122914558308 -- '6 класс опасности'
           , 716321342426122317 -- '7 класс опасности'
           , 4230875389627088545 -- '8 класс опасности'
           , 604157070827996885 -- '9 класс опасности'
           , 4504569599984049805 -- 'Опасники'
           , 1961279131436568296 -- 'Товары для дома и дачи'
           , 7283246062394458654 -- 'Товары для животных'
           , 6173212468840074022 -- 'Подгузники и туалетная бумага'
           , 7140891154007995232 -- 'Бытовая техника'
           , 8845881085734335059 -- 'Продукты +17'
           , 1775465531864137165 -- 'Вода'
           , 7064590679319570490 -- 'Бытовая химия'
           , 6522452963607389817 -- 'Книга'
           , 2747538581386642344 -- 'Одежда, Текстиль, Сумки'
           , 4980143551095494073 -- 'Обувь'
           , 1543024544232972842 -- 'Продукты'
           , 6051268096596768889 -- 'Игра, Канцтовары, Товары для детей'
           , 9216358951387548216 -- Sort
           , 7696218150898608887 -- Sort
           , 4217572752416528871 -- НонСортМ
           , 7758223693989033451 -- НонСорт-стеллаж
           , 5849049604398793466 -- Крупногабарит
           , 3170660884653643404 -- Лёгкий крупногабарит
           , 8089256920405702796 -- Лёгкий Длинномер
           , 3745374236461014676 -- Длинномер
           , 3589162341112388495 -- OverSize
           , 3038921900645476706 -- КГТ-Мезонин
           , 7402551360560286616 -- Хрупкий
           , 7584565283120360546 -- Яд
           , 8527555746102696740 -- Экземплярный
           , 1697110219020307156 -- Паллетка
           )
        group by  ai.sourcekey
    )*/
select
    --namber_id.supply_id as 'Номер поставки',
    tsk.id                                                              as task_id,
    sectr_inf.name                                                      as 'Сектор размещения',
    name.name                                                           as 'Оператор',
    case
        when to_char(start_.at + interval '3 hour', 'HH24:mi:ss') < '08:00:00'
            then to_char((start_.at - 1) + interval '3 hour', 'dd.MM.yyyy')
        else to_char(start_.at + interval '3 hour', 'dd.MM.yyyy') end   as date,
    to_char(start_.at + interval '3 hour', 'dd.MM.yyyy HH24:MI:SS')     as 'Начало задания',
    to_char(first_pl_pick + interval '3 hour', 'dd.MM.yyyy HH24:MI:SS') as 'Время первого размещения',
    to_char(end_.at + interval '3 hour', 'dd.MM.yyyy HH24:MI:SS')       as 'Окончание задания',
    to_char((end_.at - start_.at), 'HH:MI:SS')                          as 'Время выполнения задания',
    to_char((first_pl_pick - start_.at), 'HH24:MI:SS')                  as 'Время до превого размещенного товара',
    ww + isnull(count_, 0)                                              as 'Кол-во размещённого товара',
    ((ww + isnull(count_, 0)) / cell_count.cnt_cell)                    as 'товар на ячейку',
    si1.name                                                            as 'Изначальный сектор',
    sectr_inf.name                                                      as 'Конечный сектор'
    /* CASE
           when regexp_ilike(TagIDs,'9155987984438942942' ) then 'Закрытая зона'
           when regexp_ilike(TagIDs,'4277141987851467413' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'5091327832147112866' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'8689657220703050304' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'6082072584947048150' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'8021102035680062104' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'9151922122914558308' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'716321342426122317' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'4230875389627088545' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'604157070827996885' ) then 'Класс опасности'
           when regexp_ilike(TagIDs,'4504569599984049805' ) then 'Опасники'
           when regexp_ilike(TagIDs,'1775465531864137165')  then 'Вода'
           when regexp_ilike(TagIDs,'8845881085734335059' ) then 'Продукты'
           when regexp_ilike(TagIDs,'1543024544232972842' ) then 'Продукты'
           when regexp_ilike(TagIDs,'7064590679319570490' ) then 'Бытовая химия'
           when regexp_ilike(TagIDs,'7283246062394458654' ) then 'Товары для животных'
           when regexp_ilike(TagIDs,'6051268096596768889' ) then 'Игра, Канцтовары, Товары для детей'
           when regexp_ilike(TagIDs,'6173212468840074022' ) then 'Подгузники и туалетная бумага'
           when regexp_ilike(TagIDs,'7140891154007995232' ) then 'Бытовая техника'
           when regexp_ilike(TagIDs,'6522452963607389817' ) then 'Книга'
           when regexp_ilike(TagIDs,'2747538581386642344' ) then 'Одежда, Текстиль, Сумки'
           when regexp_ilike(TagIDs,'4980143551095494073' ) then 'Обувь'
           when regexp_ilike(TagIDs,'1961279131436568296' ) then 'Товары для дома и дачи'
           when regexp_ilike(TagIDs,'1697110219020307156' ) then 'Паллетка'
           else 'Микс товар'
         end as TAG_ST*/
    --start_s.sector_id,
    --pt.sector_id,
from wms_csharp_service_task.tasks tsk
         join (select *
               from wms_csharp_service_task.tasks_log start_1
               where start_1.status = 20) start_ on start_.task_id = tsk.id
         join (select *
               from wms_csharp_service_task.tasks_log end_1
               where end_1.status = 30) end_ on end_.task_id = tsk.id
         join (select task_id,
                      boxing_id,
                      case
                          when zone_id = 1612615 then 1612616
                          else zone_id
                          end as zone_id,
                      sector_id
               from csharp_service_placing.placing_tasks
               --where placing_task_status = 1
                -- and dbz_op = 'c'
             ) start_s on start_s.task_id = tsk.id
         join (select task_id, count(distinct sector_id) as r
               from csharp_service_placing.placing_tasks
                    --where placing_task_status = 3
               group by task_id) s on s.task_id = start_s.task_id
         join (select r1.reason_id,
                      count(r1.id) - count(r1.quantity) as ww,
                      sum(r1.quantity)                  as count_
                      --r1.supply_id,
                      --r1.from_id
               from wms_csharp_service_storage_all.movement_log r1
               where from_type = 3
                 and from_stock_type = 1
                 and to_stock_type = 5
                 and reason = 1
               group by r1.reason_id) namber_id on namber_id.reason_id = tsk.id
         join (select reason_id, count(distinct to_id) as cnt_cell
               from wms_csharp_service_storage_all.movement_log
               where to_type = 2
               group by reason_id) cell_count on cell_count.reason_id = tsk.id
         join (select task_id,
                      case
                          when zone_id = 1612615 then 1612616
                          else zone_id
                          end as zone_id,
                      sector_id
               from csharp_service_placing.placing_tasks) sort on sort.task_id = tsk.id
         left join wms_csharp_service_task.placing_tasks pt1 on pt1.task_id = tsk.id
         left join wms_service_employee."user" u on u.id = start_.user_id
         left join wms_service_employee.type_of_employment toe on toe.id = u.type_of_employment_id
         left join wms_service_employee.user name on name.name = u.name
         left join wms_topology.sector_info sectr_inf on sectr_inf.id = sort.sector_id
         left join wms_topology.sector_info si1 on si1.id = start_s.sector_id
         left join (select reason_id,
                           min(at) as first_pl_pick
                    from wms_csharp_service_storage_all.movement_log
                    where item_id > 0
                      and to_type = 2
                    group by reason_id) m1_first on m1_first.reason_id = tsk.id
         left join (select pi1.task_id,
                           pi1.supply_id,
                           pi1.item_id,
                           pi1.boxing_id,
                           count(pi1.placing_result) as q1
                    from csharp_service_placing.placed_instances pi1
                    where pi1.placing_result = 3
                    group by pi1.task_id,
                             pi1.supply_id,
                             pi1.item_id,
                             pi1.boxing_id
                    union all
                    select pi.task_id,
                           null        as supply_id,
                           pi.item_id,
                           pi.boxing_id,
                           pi.quantity as q1
                    from csharp_service_placing.placed_items pi
) pi1 on pi1.task_id = tsk.id
     -- left join item on pi1.item_id = item.item_id
where tsk.warehouse_id = 19262731541000
  --and sort.boxing_purpose in (30,31)
  and cast(start_.at AT TIME ZONE 'UTC' AT TIME ZONE 'MSK' as smalldatetime) >= '2022-06-13 00:00'
  and cast(start_.at AT TIME ZONE 'UTC' AT TIME ZONE 'MSK' as smalldatetime) < '2022-06-30 00:00'
group by tsk.id,
         sectr_inf.name,
         name.name,
         start_.at,
         end_.at,
         first_pl_pick,
         date,
         ww + isnull(count_, 0),
         cell_count.cnt_cell,
         si1.name
         --item.TagIDs