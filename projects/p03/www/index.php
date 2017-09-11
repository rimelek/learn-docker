<?php

file_put_contents(__DIR__ . '/access.txt', date('Y.m.d. H:i:s') . "\n", FILE_APPEND);

echo nl2br(file_get_contents(__DIR__ . '/access.txt'));
