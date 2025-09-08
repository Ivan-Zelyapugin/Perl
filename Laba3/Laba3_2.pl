use strict;
use warnings;
use List::Util qw(max);   # max(x,y) — берёт максимум из двух чисел

# ==============================
# ГЛОБАЛЬНАЯ ПЕРЕМЕННАЯ
# ==============================

my $root;   # корень бинарного дерева поиска (сначала пустой = undef)

# ==============================
# ОСНОВНОЙ ЦИКЛ МЕНЮ
# ==============================

while (1) {
    print "\nМеню:\n";
    print "1. Сгенерировать дерево случайных чисел\n";
    print "2. Добавить элемент\n";
    print "3. Вывести дерево (структура)\n";
    print "4. Вывести дерево (по уровням)\n";
    print "5. Удалить элемент\n";
    print "6. Выход\n";
    print "Ваш выбор: ";

    chomp(my $choice = <> // '');  # читаем ввод пользователя, убираем \n

    if ($choice eq '1') {
        # Генерация случайного дерева
        print "Сколько чисел сгенерировать? ";
        chomp(my $n = <> // 0);

        $root = undef;  # очищаем дерево перед генерацией
        for (1 .. $n) {
            my $val = int(rand(100));   # случайное число от 0 до 99
            insert(\$root, $val);       # вставляем его в дерево
        }
        print "Дерево сгенерировано.\n";
    }
    elsif ($choice eq '2') {
        # Добавление элемента вручную
        print "Введите число: ";
        chomp(my $val = <> // '');

        # Проверяем, что введено целое число
        if ($val =~ /^-?\d+$/) {
            insert(\$root, $val);
            print "Элемент $val добавлен.\n";
        } else {
            print "Ошибка: нужно ввести целое число.\n";
        }
    }
    elsif ($choice eq '3') {
        # Печать дерева в виде "боковой схемы"
        if ($root) {
            print "\nСтруктура дерева:\n";
            print_tree($root, "", 0);
        } else {
            print "Дерево пустое.\n";
        }
    }
    elsif ($choice eq '4') {
        # Печать дерева по уровням (BFS)
        if ($root) {
            print "\nДерево по уровням:\n";
            print_tree_levels($root);
        } else {
            print "Дерево пустое.\n";
        }
    }
    elsif ($choice eq '5') {
        # Удаление элемента
        print "Введите число для удаления: ";
        chomp(my $val = <> // '');
        if ($val =~ /^-?\d+$/) {
            if (delete_node(\$root, $val)) {
                print "Элемент $val удалён.\n";
            } else {
                print "Элемент $val не найден.\n";
            }
        } else {
            print "Ошибка: нужно ввести целое число.\n";
        }
    }
    elsif ($choice eq '6') {
        last;   # выход из программы
    }
    else {
        print "Неверный выбор!\n";
    }
}

# ==============================
# ФУНКЦИИ ДЛЯ ДЕРЕВА
# ==============================

# ---------- Вставка ----------
# insert(\$node, $val)
# $node — ссылка на "ячейку" (где может быть undef или хеш узла)
# $val  — число для вставки
sub insert {
    my ($ref, $val) = @_;

    unless ($$ref) {
        # Если текущая ячейка пустая (undef) → создаём новый узел
        $$ref = { VALUE => $val, LEFT => undef, RIGHT => undef };
        return 1;
    }

    if ($val == $$ref->{VALUE}) {
        # Если элемент уже есть — не вставляем
        warn "Элемент $val уже есть!\n";
        return 0;
    }
    elsif ($val < $$ref->{VALUE}) {
        # Меньше → идём влево (рекурсивно)
        return insert(\($$ref->{LEFT}), $val);
    }
    else {
        # Больше → идём вправо
        return insert(\($$ref->{RIGHT}), $val);
    }
}

# ---------- Красивый вывод ----------
# print_tree($node, $prefix, $is_left)
# Рисует дерево "боком"
# $prefix — отступ (строка с пробелами/│)
# $is_left — флаг (1 = узел левый, 0 = правый)
sub print_tree {
    my ($node, $prefix, $is_left) = @_;
    return unless $node;

    # Сначала печатаем правое поддерево
    if ($node->{RIGHT}) {
        print_tree($node->{RIGHT}, $prefix . ($is_left ? "│   " : "    "), 0);
    }

    # Печатаем сам узел
    print $prefix;
    print($is_left ? "└── " : "┌── ");
    print $node->{VALUE} . "\n";

    # Потом печатаем левое поддерево
    if ($node->{LEFT}) {
        print_tree($node->{LEFT}, $prefix . ($is_left ? "    " : "│   "), 1);
    }
}

# ---------- Высота дерева ----------
# tree_height($node)
# Высота = 1 + максимум(высота левого, высота правого)
# Если узла нет → 0
sub tree_height {
    my ($node) = @_;
    return 0 unless $node;
    return 1 + max(tree_height($node->{LEFT}), tree_height($node->{RIGHT}));
}

# ---------- Сбор значений по уровням ----------
# collect_levels($node, $level, $levels_ref)
# $levels_ref — ссылка на массив массивов
sub collect_levels {
    my ($node, $level, $levels) = @_;
    return unless $node;

    push @{ $levels->[$level] }, $node->{VALUE}; # добавляем число в нужный уровень

    collect_levels($node->{LEFT},  $level + 1, $levels);
    collect_levels($node->{RIGHT}, $level + 1, $levels);
}

# ---------- Печать по уровням ----------
# print_tree_levels($root)
# Использует collect_levels для сбора, потом печатает
sub print_tree_levels {
    my ($root) = @_;
    return print "Дерево пустое.\n" unless $root;

    my $h = tree_height($root);  # для информации (не обязателен)
    my @levels;
    collect_levels($root, 0, \@levels);

    for my $i (0..$#levels) {
        print "Уровень $i: ";
        print join("  ", @{ $levels[$i] });
        print "\n";
    }
}

# ---------- Удаление ----------
# delete_node(\$node, $val)
# Удаляет элемент с числом $val
# Возвращает 1, если удаление прошло успешно
sub delete_node {
    my ($ref, $val) = @_;
    return 0 unless $$ref;

    if ($val < $$ref->{VALUE}) {
        return delete_node(\($$ref->{LEFT}), $val);
    }
    elsif ($val > $$ref->{VALUE}) {
        return delete_node(\($$ref->{RIGHT}), $val);
    }
    else {
        # Нашли нужный узел
        if (!$$ref->{LEFT} && !$$ref->{RIGHT}) {
            # Лист → просто удаляем
            $$ref = undef;
        }
        elsif (!$$ref->{LEFT}) {
            # Только правый потомок
            $$ref = $$ref->{RIGHT};
        }
        elsif (!$$ref->{RIGHT}) {
            # Только левый потомок
            $$ref = $$ref->{LEFT};
        }
        else {
            # Два потомка → ищем минимальное значение справа
            my $min_ref = min_ref(\($$ref->{RIGHT}));
            $$ref->{VALUE} = $$min_ref;               # заменяем значение
            delete_node(\($$ref->{RIGHT}), $$min_ref); # удаляем дубль справа
        }
        return 1;
    }
}

# ---------- Минимальный элемент ----------
# min_ref(\$node) — возвращает ссылку на VALUE самого левого узла
sub min_ref {
    my ($ref) = @_;
    return $ref unless $$ref->{LEFT};
    return min_ref(\($$ref->{LEFT}));
}
