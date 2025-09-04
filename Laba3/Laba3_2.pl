use strict;
use warnings;
use List::Util qw(max);

my $root;  # корень дерева

while (1) {
    print "\nМеню:\n";
    print "1. Сгенерировать дерево случайных чисел\n";
    print "2. Добавить элемент\n";
    print "3. Вывести дерево (структура)\n";
    print "4. Вывести дерево (по уровням)\n";
    print "5. Удалить элемент\n";
    print "6. Выход\n";
    print "Ваш выбор: ";
    chomp(my $choice = <> // '');

    if ($choice eq '1') {
        print "Сколько чисел сгенерировать? ";
        chomp(my $n = <> // 0);
        $root = undef;
        for (1 .. $n) {
            my $val = int(rand(100));
            insert(\$root, $val);
        }
        print "Дерево сгенерировано.\n";
    }
    elsif ($choice eq '2') {
        print "Введите число: ";
        chomp(my $val = <> // '');
        if ($val =~ /^-?\d+$/) {
            insert(\$root, $val);
            print "Элемент $val добавлен.\n";
        } else {
            print "Ошибка: нужно ввести целое число.\n";
        }
    }
    elsif ($choice eq '3') {
        if ($root) {
            print "\nСтруктура дерева:\n";
            print_tree($root, "", 0);
        } else {
            print "Дерево пустое.\n";
        }
    }
    elsif ($choice eq '4') {
        if ($root) {
            print "\nДерево по уровням:\n";
            print_tree_levels($root);
        } else {
            print "Дерево пустое.\n";
        }
    }
    elsif ($choice eq '5') {
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
        last;
    }
    else {
        print "Неверный выбор!\n";
    }
}

# ==============================
# Рекурсивные подпрограммы
# ==============================

# Вставка
sub insert {
    my ($ref, $val) = @_;
    unless ($$ref) {
        $$ref = { VALUE => $val, LEFT => undef, RIGHT => undef };
        return 1;
    }

    if ($val == $$ref->{VALUE}) {
        warn "Элемент $val уже есть!\n";
        return 0;
    }
    elsif ($val < $$ref->{VALUE}) {
        return insert(\($$ref->{LEFT}), $val);
    }
    else {
        return insert(\($$ref->{RIGHT}), $val);
    }
}

# Красивый боковой вывод (ветки)
sub print_tree {
    my ($node, $prefix, $is_left) = @_;
    return unless $node;

    if ($node->{RIGHT}) {
        print_tree($node->{RIGHT}, $prefix . ($is_left ? "│   " : "    "), 0);
    }

    print $prefix;
    print($is_left ? "└── " : "┌── ");
    print $node->{VALUE} . "\n";

    if ($node->{LEFT}) {
        print_tree($node->{LEFT}, $prefix . ($is_left ? "    " : "│   "), 1);
    }
}

# Высота дерева
sub tree_height {
    my ($node) = @_;
    return 0 unless $node;
    return 1 + max(tree_height($node->{LEFT}), tree_height($node->{RIGHT}));
}

# Собираем значения по уровням
sub collect_levels {
    my ($node, $level, $levels) = @_;
    return unless $node;
    push @{ $levels->[$level] }, $node->{VALUE};
    collect_levels($node->{LEFT},  $level + 1, $levels);
    collect_levels($node->{RIGHT}, $level + 1, $levels);
}

# Вывод по уровням
sub print_tree_levels {
    my ($root) = @_;
    return print "Дерево пустое.\n" unless $root;

    my $h = tree_height($root);
    my @levels;
    collect_levels($root, 0, \@levels);

    for my $i (0..$#levels) {
        print "Уровень $i: ";
        print join("  ", @{ $levels[$i] });
        print "\n";
    }
}

# Удаление
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
        # нашли узел
        if (!$$ref->{LEFT} && !$$ref->{RIGHT}) {
            $$ref = undef;   # лист
        }
        elsif (!$$ref->{LEFT}) {
            $$ref = $$ref->{RIGHT}; # только правый потомок
        }
        elsif (!$$ref->{RIGHT}) {
            $$ref = $$ref->{LEFT};  # только левый потомок
        }
        else {
            # два потомка → ищем минимум в правом поддереве
            my $min_ref = min_ref(\($$ref->{RIGHT}));
            $$ref->{VALUE} = $$min_ref;
            delete_node(\($$ref->{RIGHT}), $$min_ref);
        }
        return 1;
    }
}

# Находим минимальное значение (левый самый узел)
sub min_ref {
    my ($ref) = @_;
    return $ref unless $$ref->{LEFT};
    return min_ref(\($$ref->{LEFT}));
}
