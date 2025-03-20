-- ПЕСОЧНИЦА СПРИНТА № 3

-- 1. Выводим ТОП-30 регионов по количеству зарегестрированных доноров
SELECT region,
COUNT(DISTINCT id)
FROM donorsearch.user_anon_data 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 30;

-- 2. Динамика количества донаций в месяц за 2022 и 2023 года
select EXTRACT(YEAR FROM donation_date) AS year,
EXTRACT(MONTH FROM donation_date) AS month,
COUNT(*) AS total_donation
from donorsearch.donation_anon da 
WHERE EXTRACT(YEAR FROM donation_date) IN('2022', '2023')
GROUP BY 1, 2
ORDER BY 1, 2;

-- 3. Считаем ТОП-10 самых активных пользователей
SELECT id,
SUM(donations_before_registration + confirmed_donations) AS total_id_donation
FROM donorsearch.user_anon_data
GROUP BY 1
HAVING SUM(donations_before_registration + confirmed_donations) IS NOT NULL
ORDER BY 2 DESC
LIMIT 10; 

-- 4.1. Считаем средне количество донаций в разрезе использованных бонусов
SELECT user_bonus_count,
ROUND(AVG(donation_count)) AS avg_donations
FROM donorsearch.user_anon_bonus uab
GROUP BY 1
ORDER BY 2 DESC;

-- 4.2. Разделяем выборку на группы по количеству использованных бонусов и сравниваем среднее количество донаций
WITH sub AS (SELECT user_bonus_count,
                    NTILE(10) OVER (ORDER BY user_bonus_count) AS nt,
                    donation_count
             FROM donorsearch.user_anon_bonus uab)
SELECT nt,
MIN(user_bonus_count) AS min_bonus,
MAX(user_bonus_count) AS max_bonus,
ROUND(AVG(donation_count)) AS avg_donations
FROM sub 
GROUP BY 1
ORDER BY 1;

-- 5. Смотрим на успешность каналов привлечения, оценивая количество пользователей и среднее количество донаций
WITH sub_channel AS (SELECT CASE WHEN autho_vk = true THEN 'VK'
                                 WHEN autho_ok = true THEN 'OK'
                                 WHEN autho_tg = true THEN 'TG'
                                 WHEN autho_yandex = true THEN 'YANDEX'
                                 WHEN autho_google = true THEN 'GOOGLE' 
                                 ELSE 'NO INFO'END AS channel,
                                 donations_before_registration,
                                 confirmed_donations,
                                 id
                    FROM donorsearch.user_anon_data)
SELECT channel,
       COUNT(distinct id) AS total_users,
       ROUND(AVG(donations_before_registration + confirmed_donations)) AS avg_id_donation
FROM sub_channel
GROUP BY 1
ORDER BY 2 DESC;
