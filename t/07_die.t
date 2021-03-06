use strict;
use Test::More;

{
    package Jopa;
    use Class::Accessor::Inherited::XS {
        constructor => 'new',
        inherited   => 'foo',
        object      => 'bar',
        class       => 'fuz',
    };
}

sub exception (&) {
    $@ = undef;
    eval { shift->() };
    $@
}

like exception {Jopa::foo()}, qr/Usage:/;
like exception {Jopa::new()}, qr/Usage:/;
like exception {Jopa::fuz()}, qr/Usage:/;

my $foometh = Jopa->can('foo');

like exception {$foometh->(bless [], 'Jopa')}, qr/hash-based/;
like exception {$foometh->([])}, qr/hash-based/;
like exception {$foometh->({})}, qr/glob to package/;

my $scalarobj = bless \(my $z), 'Jopa';
like exception {$scalarobj->foo}, qr/hash-based/;

like exception {Jopa->bar}, qr/on non-object/;

like exception {Jopa->new(1)}, qr/^Odd/;
like exception {Jopa->new(1..3)}, qr/^Odd/;
like exception {Jopa->new([])}, qr/^Odd/;

done_testing;
