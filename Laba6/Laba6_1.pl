#!/usr/bin/perl
use strict;
use warnings;
use utf8;                          # исходник скрипта в UTF-8
use open qw(:std :encoding(UTF-8));# STDIN/STDOUT/STDERR в UTF-8
use Encode::Locale;                # чтобы корректно декодировать @ARGV по локали
use File::Find;

# декодируем аргументы командной строки в "широкие" строки Perl
Encode::Locale::decode_argv();

# Проверка аргументов
if (@ARGV < 2) {
    die "Использование: $0 <каталог> <строка_поиска> [i]\n" .
        "  где [i] - необязательный флаг, означающий поиск без учета регистра\n";
}

my $root_dir    = shift @ARGV;
my $pattern     = shift @ARGV;
my $ignore_case = shift @ARGV // '';

# Компилируем регулярное выражение (с проверкой на синтаксис)
my $regex;
eval {
    $regex = ($ignore_case eq 'i') ? qr/$pattern/i : qr/$pattern/;
};
if ($@) {
    die "Некорректный шаблон регулярного выражения: $@\n";
}

my %report;

find(\&process_file, $root_dir);

print "=== Отчет по файлам ===\n";
foreach my $file (sort keys %report) {
    print "$file : $report{$file}\n";
}

sub process_file {
    return if -d $_;  # пропускаем каталоги

    my $file = $File::Find::name;
    my $count = 0;

    # Открываем файл, явно указывая декодирование из UTF-8.
    # Если ваши файлы в CP1251, замените 'UTF-8' на 'CP1251' (см. ниже).
    open my $fh, '<:encoding(UTF-8)', $file or return;

    while (my $line = <$fh>) {
        # считаем все вхождения
        while ($line =~ /$regex/g) {
            $count++;
        }
    }
    close $fh;

    $report{$file} = $count if $count > 0;
}
