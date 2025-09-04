#!/usr/bin/perl
use strict;
use warnings;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDIN,  ':encoding(UTF-8)';

# --- Чтение массива ---
sub read_array {
    my $prompt = shift;
    print "$prompt (по одному элементу на строку, пустая строка — окончание ввода):\n";
    my @arr;
    while (my $line = <STDIN>) {
        chomp $line;
        last if $line eq '';
        push @arr, $line;
    }
    return @arr;
}

# --- Универсальная сортировка ---
sub sort_list {
    my @list = @_;
    return () unless @list;
    # определим — все ли элементы целочисленные (без точки)
    my $all_int = 1;
    for (@list) {
        $all_int = 0 unless defined $_ && /^-?\d+$/;
        last unless $all_int;
    }
    return $all_int ? (sort { $a <=> $b } @list) : (sort @list);
}

# --- Операции множеств (работаем с уникальными элементами через хеш) ---
sub operations_sets {
    my ($a1, $a2) = @_;
    my %seen1 = map { $_ => 1 } @$a1;   # уникальные A
    my %seen2 = map { $_ => 1 } @$a2;   # уникальные B

    # Объединение (унитарный хеш обоих ключей)
    my %union_h = (%seen1, %seen2);
    my @union = sort_list(keys %union_h);

    # Пересечение: ключи, которые есть и в первом, и во втором
    my @intersection = sort_list(grep { exists $seen2{$_} } keys %seen1);

    # Разность A - B: уникальные ключи A, которых нет в B
    my @diff_ab = sort_list(grep { not exists $seen2{$_} } keys %seen1);

    # Разность B - A: уникальные ключи B, которых нет в A
    my @diff_ba = sort_list(grep { not exists $seen1{$_} } keys %seen2);

    # Симметричная разность = (A - B) U (B - A) — объединим и уникализируем
    my %sym_h = map { $_ => 1 } (@diff_ab, @diff_ba);
    my @sym_diff = sort_list(keys %sym_h);

    # Печать результатов (аккуратно с пустыми множествами)
    print "\n--- Результаты множеств ---\n";
    print "Объединение: ", @union ? join(' ', @union) : "(пусто)", "\n";
    print "Пересечение: ", @intersection ? join(' ', @intersection) : "(пусто)", "\n";
    print "Разность (array1 - array2): ", @diff_ab ? join(' ', @diff_ab) : "(пусто)", "\n";
    print "Симметричная разность: ", @sym_diff ? join(' ', @sym_diff) : "(пусто)", "\n";
}

# --- Попарная перестановка элементов первого массива ---
sub swap_pairs {
    my ($a1) = @_;
    my @swapped = @$a1;           # работаем с копией
    for (my $i = 0; $i+1 < @swapped; $i += 2) {
        ($swapped[$i], $swapped[$i+1]) = ($swapped[$i+1], $swapped[$i]);
    }
    print "\n--- Попарная перестановка первого массива ---\n";
    print @swapped ? join(' ', @swapped) . "\n" : "(пустой массив)\n";
}

# --- Чередование (останавливаемся, как только один массив закончился) ---
sub merge_alternate {
    my ($a1, $a2) = @_;
    my $min = @$a1 < @$a2 ? @$a1 : @$a2;   # ОСТАНОВИТЬСЯ, когда один закончится
    my @merged;
    for my $i (0..$min-1) {
        push @merged, $a1->[$i], $a2->[$i];
    }
    print "\n--- Чередующийся массив (до конца меньшего массива) ---\n";
    print @merged ? join(' ', @merged) . "\n" : "(пусто)\n";
}

# --- Меню для работы с массивами ---
sub menu_arrays {
    my ($a1_ref, $a2_ref) = @_;
    while (1) {
        print "\nМеню работы с массивами:\n";
        print "1. Операции множеств (объединение, пересечение, разность, симметричная разность)\n";
        print "2. Попарная перестановка элементов первого массива\n";
        print "3. Построение чередующегося массива (остановка при окончании одного из массивов)\n";
        print "4. Назад\n";
        print "Выберите действие: ";
        chomp(my $c = <STDIN>);
        if ($c eq '1') {
            operations_sets($a1_ref, $a2_ref);
        } elsif ($c eq '2') {
            swap_pairs($a1_ref);
        } elsif ($c eq '3') {
            merge_alternate($a1_ref, $a2_ref);
        } elsif ($c eq '4') {
            last;
        } else {
            print "Некорректный выбор.\n";
        }
    }
}

# --- Меню работы со строковым списком (хеш) ---
sub menu_strings {
    my %strings;
    while (1) {
        print "\nМеню работы со строками (лексикографический порядок):\n";
        print "1. Добавить строку\n";
        print "2. Удалить строку\n";
        print "3. Показать список\n";
        print "4. Назад\n";
        print "Выберите действие: ";
        chomp(my $c = <STDIN>);
        if ($c eq '1') {
            print "Введите строку для добавления: ";
            chomp(my $s = <STDIN>);
            $strings{$s} = 1;
            print "Добавлено.\n";
        } elsif ($c eq '2') {
            print "Введите строку для удаления: ";
            chomp(my $s = <STDIN>);
            if (exists $strings{$s}) {
                delete $strings{$s};
                print "Удалено.\n";
            } else {
                print "Такой строки нет.\n";
            }
        } elsif ($c eq '3') {
            print "Список (лексикографически):\n";
            my @out = sort keys %strings;
            print @out ? join("\n", @out) . "\n" : "(пусто)\n";
        } elsif ($c eq '4') {
            last;
        } else {
            print "Некорректный выбор.\n";
        }
    }
}

# --- main ---
print "=== Ввод массивов ===\n";
my @array1 = read_array("Введите элементы первого массива");
my @array2 = read_array("Введите элементы второго массива");

while (1) {
    print "\nГлавное меню:\n1. Работа с массивами\n2. Работа со строками (хеш)\n3. Выход\nВыберите: ";
    chomp(my $ch = <STDIN>);
    if ($ch eq '1') {
        menu_arrays(\@array1, \@array2);
    } elsif ($ch eq '2') {
        menu_strings();
    } elsif ($ch eq '3') {
        last;
    } else {
        print "Некорректный выбор.\n";
    }
}
