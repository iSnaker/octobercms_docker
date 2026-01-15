<?php
/*
| For additional options see
| https://github.com/octobercms/october/blob/master/config/app.php
*/

return [
    'debug' => env('APP_DEBUG', true),
    'url' => env('APP_URL', 'http://localhost:8888'),
    'timezone' => env('TZ', 'UTC'),
    'key' => env('APP_KEY', 'SomeRandom'),
    'locale' => env('APP_LOCALE', 'en'),
];
    