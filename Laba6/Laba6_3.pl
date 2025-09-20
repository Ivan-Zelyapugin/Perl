#!/usr/bin/perl
use strict;
use warnings;

# --- Подпрограмма перевода римского числа в арабское ---
sub roman_to_arabic {
    my $roman = shift;
    my %values = (
        M => 1000,
        D => 500,
        C => 100,
        L => 50,
        X => 10,
        V => 5,
        I => 1,
    );

    my $total = 0;
    my $prev = 0;

    # Проверка на пустую строку
    return 0 unless $roman;

    # Читаем справа налево
    foreach my $char (reverse split //, $roman) {
        # Проверка на валидность символа
        unless (exists $values{$char}) {
            warn "Некорректный символ '$char' в числе '$roman'\n";
            return 0;
        }
        my $value = $values{$char};
        if ($value < $prev) {
            $total -= $value;
        } else {
            $total += $value;
            $prev = $value;
        }
    }
    return $total;
}

# --- Чтение пути к файлу ---
my $infile = $ARGV[0];

# Если путь не передан через аргументы, запрашиваем у пользователя
unless ($infile) {
    print "Введите имя входного файла: ";
    chomp($infile = <STDIN>);
}

# Проверка существования файла
unless (-e $infile) {
    die "Файл $infile не существует\n";
}

open my $in, "<", $infile or die "Не удалось открыть $infile: $!\n";

# Считываем файл построчно
my @numbers;
while (my $line = <$in>) {
    chomp $line;
    # Разделяем строку на слова (римские числа)
    push @numbers, split /\s+/, $line;
}
close $in;

# Регулярка для проверки валидности римского числа (1..3999)
my $roman_regex = qr/^(?:M{0,3})(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3})$/;

# Преобразуем каждое число
my @results;
foreach my $roman (@numbers) {
    # Пропускаем пустые строки
    next unless $roman;
    # Проверяем валидность римского числа
    if ($roman =~ $roman_regex) {
        my $arabic = roman_to_arabic($roman);
        push @results, $arabic if $arabic > 0 && $arabic <= 3999;
    } else {
        warn "Некорректное римское число: '$roman'\n";
        push @results, 0;
    }
}

# Запишем результат в файл
my $outfile = "out_2.txt";
open my $out, ">", $outfile or die "Не удалось создать $outfile: $!\n";
print $out join(" ", @results), "\n";
close $out;

print "Готово! Результат сохранён в $outfile\n";