<?php

file_put_contents(__DIR__ . '/access.txt', date('Y.m.d. H:i:s') . "\n", FILE_APPEND);

echo 'P06WEB1: ' . getenv('HOSTNAME') . '<br/>';
echo nl2br(file_get_contents(__DIR__ . '/access.txt'));
