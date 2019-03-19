<?php

$requestUri = $_SERVER['REQUEST_URI'];

// буквы в верхнем регистре
if(preg_match('/[A-Z]/', $requestUri) === 1){
    $requestUri = strtolower($requestUri);
}

// повторяющиеся слеши
if (strpos($requestUri, '//') !== false) {
    $requestUri = preg_replace('/\/\/+/', '/', $requestUri);
}

$protocol = !empty($_SERVER['HTTPS']) ? 'https://' : 'http://';
$url = $protocol.$_SERVER['SERVER_NAME'].$requestUri;
header( 'Location: '.$url, true, 301 );
exit(0);