#!/usr/bin/perl
use strict;
use warnings;

# ===============================
# Функция: чтение массива
# ===============================
sub read_array {
    my $prompt = shift;
    print "$prompt (пустая строка — окончание ввода):\n";
    my @arr;
    while (my $line = <>) {
        chomp $line;
        last if $line eq '';
        push @arr, $line;
    }
    return @arr;
}

# ===============================
# Удаление дубликатов
# ===============================
sub unique_array {
    my @arr = @_;
    my @uniq;
    for my $el (@arr) {
        my $found = 0;
        for my $u (@uniq) {
            if ($u eq $el) { $found = 1; last }
        }
        push @uniq, $el if !$found;
    }
    return @uniq;
}

# ===============================
# Разность массивов
# ===============================
sub diff_arrays {
    my ($arr1_ref, $arr2_ref) = @_;
    my @diff;
    for my $x (@$arr1_ref) {
        my $found = 0;
        for my $y (@$arr2_ref) {
            if ($x eq $y) { $found = 1; last }
        }
        push @diff, $x if !$found;
    }
    return @diff;
}

# ===============================
# Операции множеств
# ===============================
sub operations_sets {
    my ($a1, $a2) = @_;

    my @union = unique_array(@$a1, @$a2);

    my @intersection;
    for my $x (@$a1) {
        for my $y (@$a2) {
            if ($x eq $y) { push @intersection, $x; last }
        }
    }
    @intersection = unique_array(@intersection);

    my @diff_ab = diff_arrays($a1, $a2);
    my @diff_ba = diff_arrays($a2, $a1);
    my @sym_diff = unique_array(@diff_ab, @diff_ba);

    print "\n--- Результаты множеств ---\n";
    print "Объединение: @union\n";
    print "Пересечение: @intersection\n";
    print "Разность (array1 - array2): @diff_ab\n";
    print "Разность (array2 - array1): @diff_ba\n";
    print "Симметричная разность: @sym_diff\n";
}

# ===============================
# Попарная перестановка
# ===============================
sub swap_pairs {
    my ($arr_ref) = @_;
    my @swapped = @$arr_ref;
    for (my $i = 0; $i+1 < @swapped; $i += 2) {
        @swapped[$i, $i+1] = @swapped[$i+1, $i];
    }
    print "\n--- Попарная перестановка ---\n";
    print "@swapped\n";
}

# ===============================
# Чередование массивов
# ===============================
sub merge_alternate {
    my ($a1, $a2) = @_;
    my $min = @$a1 < @$a2 ? @$a1 : @$a2;
    my @merged;
    for my $i (0..$min-1) {
        push @merged, $a1->[$i], $a2->[$i];
    }
    print "\n--- Чередующийся массив ---\n";
    print @merged ? "@merged\n" : "(пусто)\n";
}

# ===============================
# Меню работы с массивами
# ===============================
sub menu_arrays {
    my ($a1_ref, $a2_ref) = @_;
    while (1) {
        print "\nМеню:\n1. Операции множеств\n2. Попарная перестановка\n3. Чередующийся массив\n4. Назад\nВыберите: ";
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

# ===============================
# Меню работы со строками (хеш)
# ===============================
sub menu_strings {
    my %strings;
    while (1) {
        print "\nМеню строк:\n1. Добавить\n2. Удалить\n3. Показать\n4. Назад\nВыберите: ";
        chomp(my $c = <STDIN>);
        if ($c eq '1') {
            print "Введите строку: ";
            chomp(my $s = <STDIN>);
            $strings{$s} = 1;
        } elsif ($c eq '2') {
            print "Введите строку: ";
            chomp(my $s = <STDIN>);
            delete $strings{$s};
        } elsif ($c eq '3') {
            print "Список:\n";
            print join("\n", sort keys %strings) || "(пусто)", "\n";
        } elsif ($c eq '4') {
            last;
        } else {
            print "Некорректный выбор.\n";
        }
    }
}

# ===============================
# main
# ===============================
print "=== Ввод массивов ===\n";
my @array1 = read_array("Первый массив");
my @array2 = read_array("Второй массив");

while (1) {
    print "\nГлавное меню:\n1. Массивы\n2. Строки\n3. Выход\nВыберите: ";
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
