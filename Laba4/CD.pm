package CD;
require Exporter;
@ISA = qw(UNIVERSAL Exporter);
@EXPORT = qw(new DESTROY display_info compare_two);

sub new {
    my $classname = shift;   
    my $self = {};

    $self->{title}  = shift;
    $self->{artist} = shift;
    $self->{year}   = shift;
    $self->{genre}  = shift;

    bless $self, $classname; 
    return $self;
}

sub DESTROY {
    my $ref = shift;
    $ref->SUPER::DESTROY;
}

sub display_info {
    my $self = shift;
    return ($self->{title}, $self->{artist}, $self->{year}, $self->{genre});
}

sub compare_two {
    my ($a, $b, $field) = @_;
    if ($field eq 'year') {
        return $a->{$field} <=> $b->{$field};
    } else {
        return $a->{$field} cmp $b->{$field};
    }
}

1;
