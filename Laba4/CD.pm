package CD;
use strict;
use warnings;

# ==============================
# Конструктор
# ==============================
sub new {
    my ($class, %args) = @_;
    my $self = {
        title  => $args{title}  // 'Неизвестное название',
        artist => $args{artist} // 'Неизвестный исполнитель',
        year   => $args{year}   // 0,
        genre  => $args{genre}  // 'Неизвестный жанр',
    };
    bless $self, $class;
    return $self;
}

# ==============================
# Печать информации
# ==============================
sub display_info {
    my $self = shift;
    print "Название:     ", $self->{title},  "\n";
    print "Исполнитель:  ", $self->{artist}, "\n";
    print "Год выпуска:  ", $self->{year},   "\n";
    print "Жанр:         ", $self->{genre},  "\n";
}

# ==============================
# Обновление информации
# ==============================
sub update_info {
    my ($self, %info) = @_;
    $self->{title}  = $info{title}  if defined $info{title};
    $self->{artist} = $info{artist} if defined $info{artist};
    $self->{year}   = $info{year}   if defined $info{year};
    $self->{genre}  = $info{genre}  if defined $info{genre};
}

# ==============================
# Сравнение двух объектов
# ==============================
# compare($other, $field)
# возвращает -1, 0 или 1
sub compare {
    my ($self, $other, $field) = @_;
    $field //= 'year';   # по умолчанию сравниваем по году

    if (!exists $self->{$field} || !exists $other->{$field}) {
        die "Нет такого поля для сравнения: $field\n";
    }

    # строковые поля
    if ($field eq 'title' || $field eq 'artist' || $field eq 'genre') {
        return $self->{$field} cmp $other->{$field};
    }

    # числовые поля
    return $self->{$field} <=> $other->{$field};
}

# ==============================
# Успешная загрузка модуля
# ==============================
1;
