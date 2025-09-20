#!/usr/bin/perl
use strict;
use warnings;
use File::Find;

# Проверка аргументов
if (@ARGV < 2) {
    die "Использование: $0 <каталог> <строка_поиска> [i]\n" .
        "  где [i] - необязательный флаг, означающий поиск без учета регистра\n";
}

my $root_dir = shift @ARGV;        # Корень дерева каталогов
my $pattern  = shift @ARGV;        # Последовательность для поиска
my $ignore_case = shift @ARGV;     # Режим регистра (i - без учета регистра)

# Формируем регулярное выражение
my $regex;
if (defined $ignore_case && $ignore_case eq 'i') {
    $regex = qr/$pattern/i;
} else {
    $regex = qr/$pattern/;
}

# Хэш для отчета: имя файла -> количество совпадений
my %report;

# Рекурсивный обход каталогов
find(\&process_file, $root_dir);

# Вывод отчета
print "=== Отчет по файлам ===\n";
foreach my $file (sort keys %report) {
    print "$file : $report{$file}\n";
}

# ---- Подпрограмма обработки файла ----
sub process_file {
    return if -d $_;  # Пропускаем каталоги

    my $file = $File::Find::name;
    my $count = 0;

    # Открываем файл в безопасном режиме
    open my $fh, "<", $file or return;

    while (my $line = <$fh>) {
        my @matches = ($line =~ /$regex/g);  # Глобальный поиск
        $count += scalar @matches if @matches;
    }
    close $fh;

    # Если были совпадения – заносим в отчет
    $report{$file} = $count if $count > 0;
}
