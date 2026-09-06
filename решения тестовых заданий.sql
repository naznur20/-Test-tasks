-- 1. Во вкладке "Данные об аудитории" информация о пользователях, посетивших наше приложение в ноябре. Чему равен MAU продукта? 
-- *MAU (Monthly Active Users) — это метрика, используемая для измерения активности пользователей в течение одного месяца. Она показывает количество уникальных пользователей, которые взаимодействовали с продуктом, сервисом или приложением хотя бы один раз за последний месяц.


SELECT COUNT(DISTINCT user_id) AS mau
FROM university.`данные об аудитории`
WHERE date BETWEEN '2023-11-01' AND '2023-11-30';


-- 2. Используя вкладку "Данные об аудитории", посчитайте, чему будет равен DAU 
-- *DAU (Daily Active Users) — это метрика, которая показывает количество уникальных пользователей, которые взаимодействовали с продуктом, приложением или сервисом хотя бы один раз в течение дня. DAU помогает понять, сколько пользователей активно пользуются продуктом каждый день.

SELECT SUM(daily_users) / 30 AS dau
FROM (
    SELECT date, COUNT(DISTINCT user_id) AS daily_users
    FROM university.`данные об аудитории`
    WHERE date BETWEEN '2023-11-01' AND '2023-11-30'
    GROUP BY date
) AS t;

-- 3. Используя вкладку "Данные об аудитории", посчитайте, чему будет равен retention первого дня у пользователей, пришедших в продукт 1 ноября 
-- *Retention (удержание пользователей) — это метрика, которая показывает, сколько пользователей продолжает пользоваться продуктом через определенный промежуток времени после первоначального взаимодействия. Retention можно рассчитать как процент пользователей, вернувшихся в продукт через определенное время (например, через 1 день, 1 неделю, 1 месяц) от количества всех новых пользователей.
SELECT 
    COUNT(DISTINCT t1.user_id) AS cohort_size,
    COUNT(DISTINCT t2.user_id) AS returned_day1,
    ROUND(COUNT(DISTINCT t2.user_id) * 100.0 / COUNT(DISTINCT t1.user_id), 1) AS retention_day1_pct
FROM university.`данные об аудитории` t1
LEFT JOIN university.`данные об аудитории` t2
    ON t1.user_id = t2.user_id AND t2.date = '2023-11-02'
WHERE t1.date = '2023-11-01';


-- 5. Во вкладке "Данные об аудитории" есть информация о том, сколько объявлений посмотрел каждый пользователь (view_adverts). Посчитайте пользовательскую конверсию в просмотр объявления за ноябрь? (в пользователях) 
-- * Пользовательская конверсия — это метрика, которая показывает, какой процент пользователей выполнил целевое действие по отношению к общему количеству пользователей. В контексте веб-сайтов это может быть действие, такое как просмотр объявления или клик по рекламному баннеру. 

SELECT 
    ROUND(
        COUNT(DISTINCT CASE WHEN view_adverts > 0 THEN user_id END) * 100.0 
        / COUNT(DISTINCT user_id), 
        1
    ) AS conversion_pct
FROM university.`данные об аудитории`
WHERE date BETWEEN '2023-11-01' AND '2023-11-30';

-- 6. Используя информацию из вкладки "Данные об аудитории", посчитайте среднее количество просмотренных объявлений на пользователя в ноябре
SELECT 
    ROUND(SUM(view_adverts) * 1.0 / COUNT(DISTINCT user_id), 1) AS avg_views_per_user
FROM university.`данные об аудитории`
WHERE date BETWEEN '2023-11-01' AND '2023-11-30';

-- 7. Мы провели опрос среди 2000 пользователей. Из них 500 «критики», 1200 «сторонники» и 300 «нейтралы». Посчитайте, чему будет равен NPS 
-- * NPS (Net Promoter Score) — это метрика, которая измеряет лояльность пользователей к компании или продукту и делит их на три группы: Сторонники (Promoters) , Нейтралы (Passives),  Критики (Detractors). NPS высчитывается как (% сторонников - % критиков).

SELECT 
    ROUND((1200 - 500) * 100.0 / 2000, 1) AS nps
;

-- 8. Во вкладке "Данные АБ-тестов" результаты трех несвязанных АБ тестов для ARPU (общая выручка/общее количество пользователей).
-- Посмотрите на результаты тестов и интерпретируйте их. Напишите значения p-value, которые вы получили.
-- Шаг 1. Собрать ARPU по группам (SQL)
SELECT 
    experiment_num,
    experiment_group,
    COUNT(DISTINCT user_id) AS users,
    SUM(revenue) AS total_revenue,
    ROUND(SUM(revenue) * 1.0 / COUNT(DISTINCT user_id), 2) AS arpu
FROM university.`данные аб тестов`
GROUP BY experiment_num, experiment_group
ORDER BY experiment_num, experiment_group;

-- Шаг 2. Посчитать p-value в Python

-- 9. По датасету с листерами посчитайте средний доход на пользователя 
SELECT 
    SUM(revenue) * 1.0 / COUNT(DISTINCT user_id) AS arpu
FROM university.`данные для тестового задания`;

-- 10. По датасету с листерами посчитайте медиану возраста пользователя 
SELECT AVG(age) AS median_age
FROM (
    SELECT age,
           ROW_NUMBER() OVER (ORDER BY age) AS rn,
           COUNT(*) OVER () AS cnt
    FROM (SELECT DISTINCT user_id, age FROM university.`данные для тестового задания`) u
) ranked
WHERE rn IN (FLOOR((cnt+1)/2), CEIL((cnt+1)/2));
