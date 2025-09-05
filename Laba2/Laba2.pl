# --- Чтение массива ---
sub read_array {
    my $prompt = shift;  # shift берёт первый аргумент функции
    print "$prompt (по одному элементу на строку, пустая строка — окончание ввода):\n";
    my @arr;             # объявляем массив
    while (my $line = <STDIN>) {   # <STDIN> читает строку из ввода
        chomp $line;     # chomp удаляет символ перевода строки \n
        last if $line eq ''; # eq – сравнение строк (равенство). Если строка пустая, выходим из цикла
        push @arr, $line; # push добавляет элемент в конец массива
    }
    return @arr;         # возвращаем массив
}

# --- Универсальная сортировка ---
sub sort_list {
    my @list = @_;       # @_ содержит список всех аргументов функции
    return () unless @list; # unless = "если не". Если массив пуст, вернуть пустой список
    my $all_int = 1;     # предполагаем, что все элементы – целые числа
    for (@list) {        # перебор элементов массива
        # ^ - начало строки, -? - возможный минус, \d+ - одна или больше цифр, $ - конец строки
        $all_int = 0 unless defined $_ && /^-?\d+$/; 
    }
    # если все числа – сортируем численно через <=> (оператор сравнения чисел)
    # иначе – лексикографически (по алфавиту)
    return $all_int ? (sort { $a <=> $b } @list) : (sort @list);
}

# --- Удаление дубликатов ---
sub unique_array {
    my @arr = @_;
    my @uniq;  # новый массив без повторов
    for my $el (@arr) {       # внешний цикл
        my $found = 0;        # флаг – найден ли уже элемент
        for my $u (@uniq) {   # перебор уникальных элементов
            if ($u eq $el) { $found = 1; last; } # eq – сравнение строк, last – выход из цикла
        }
        push @uniq, $el unless $found; # добавляем, если не нашли дубликат
    }
    return @uniq;
}

# --- Операции множеств через массивы ---
sub operations_sets {
    my ($a1, $a2) = @_; # ссылки на массивы (передаются как указатели)

    my @A = unique_array(@$a1); # @$a1 – разыменование ссылки: превращает ссылку в массив
    my @B = unique_array(@$a2);

    # Объединение
    my @union = unique_array(@A, @B);

    # Пересечение
    my @intersection;
    for my $x (@A) {
        for my $y (@B) {
            if ($x eq $y) {  # если элементы равны
                push @intersection, $x;
                last;        # прерываем внутренний цикл
            }
        }
    }
    @intersection = unique_array(@intersection);

    # Разность A - B
    my @diff_ab;
    for my $x (@A) {
        my $found = 0;
        for my $y (@B) {
            if ($x eq $y) { $found = 1; last; }
        }
        push @diff_ab, $x unless $found;
    }

    # Разность B - A
    my @diff_ba;
    for my $y (@B) {
        my $found = 0;
        for my $x (@A) {
            if ($x eq $y) { $found = 1; last; }
        }
        push @diff_ba, $y unless $found;
    }

    # Симметричная разность = (A-B) + (B-A)
    my @sym_diff = unique_array(@diff_ab, @diff_ba);

    # Сортировка
    @union        = sort_list(@union);
    @intersection = sort_list(@intersection);
    @diff_ab      = sort_list(@diff_ab);
    @diff_ba      = sort_list(@diff_ba);
    @sym_diff     = sort_list(@sym_diff);

    # Вывод
    print "\n--- Результаты множеств ---\n";
    print "Объединение: ", @union ? join(' ', @union) : "(пусто)", "\n";
    print "Пересечение: ", @intersection ? join(' ', @intersection) : "(пусто)", "\n";
    print "Разность (array1 - array2): ", @diff_ab ? join(' ', @diff_ab) : "(пусто)", "\n";
    print "Разность (array2 - array1): ", @diff_ba ? join(' ', @diff_ba) : "(пусто)", "\n";
    print "Симметричная разность: ", @sym_diff ? join(' ', @sym_diff) : "(пусто)", "\n";
}

# --- Попарная перестановка элементов ---
sub swap_pairs {
    my ($a1) = @_;
    my @swapped = @$a1; # делаем копию массива
    for (my $i = 0; $i+1 < @swapped; $i += 2) {
        # @array[$i,$i+1] – срез массива по индексам
        # левая и правая часть меняются местами
        @swapped[$i,$i+1] = @swapped[$i+1,$i];
    }
    print "\n--- Попарная перестановка первого массива ---\n";
    print @swapped ? join(' ', @swapped) . "\n" : "(пустой массив)\n";
}

# --- Чередование ---
sub merge_alternate {
    my ($a1, $a2) = @_;
    my $min = @$a1 < @$a2 ? @$a1 : @$a2; # ? : – тернарный оператор
    my @merged;
    for my $i (0..$min-1) { # 0..$min-1 – диапазон чисел
        push @merged, $a1->[$i], $a2->[$i]; # -> доступ к элементу массива по ссылке
    }
    print "\n--- Чередующийся массив (до конца меньшего массива) ---\n";
    print @merged ? join(' ', @merged) . "\n" : "(пусто)\n";
}

# --- Меню работы с массивами ---
sub menu_arrays {
    my ($a1_ref, $a2_ref) = @_;
    while (1) {
        print "\nМеню работы с массивами:\n";
        print "1. Операции множеств\n";
        print "2. Попарная перестановка\n";
        print "3. Чередующийся массив\n";
        print "4. Назад\n";
        print "Выберите действие: ";
        chomp(my $c = <STDIN>); # chomp – убираем \n
        if ($c eq '1') {
            operations_sets($a1_ref, $a2_ref);
        } elsif ($c eq '2') {
            swap_pairs($a1_ref);
        } elsif ($c eq '3') {
            merge_alternate($a1_ref, $a2_ref);
        } elsif ($c eq '4') {
            last; # выход из цикла while
        } else {
            print "Некорректный выбор.\n";
        }
    }
}

# --- Меню работы со строками (хеш) ---
sub menu_strings {
    my %strings; # % – хеш (ключ-значение)
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
            $strings{$s} = 1; # кладём в хеш ключ со значением 1 (дубликаты перезаписываются)
            print "Добавлено.\n";
        } elsif ($c eq '2') {
            print "Введите строку для удаления: ";
            chomp(my $s = <STDIN>);
            if (exists $strings{$s}) { # exists – проверка наличия ключа в хеше
                delete $strings{$s};  # delete – удаление ключа
                print "Удалено.\n";
            } else {
                print "Такой строки нет.\n";
            }
        } elsif ($c eq '3') {
            print "Список (лексикографически):\n";
            my @out = sort keys %strings; # keys – список ключей хеша
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
        menu_arrays(\@array1, \@array2); # \@array1 – ссылка на массив
    } elsif ($ch eq '2') {
        menu_strings();
    } elsif ($ch eq '3') {
        last;
    } else {
        print "Некорректный выбор.\n";
    }
}
