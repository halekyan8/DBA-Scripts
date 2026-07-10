/*
Shows Database Mail items from msdb, including recipients, subject, request date,
and sent status, newest first.
*/
SELECT
    [mailitem_id],
    [recipients],
    [subject],
    [send_request_date],
    [sent_status]
FROM
    [msdb].[dbo].[sysmail_allitems]
ORDER BY
    [send_request_date] DESC;
