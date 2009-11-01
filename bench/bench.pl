#!perl

use Class::Accessor::Inherited::XS;
use Class::Accessor::Grouped;
use Class::XSAccessor;
use strict;
use Benchmark qw/timethis timethese/;

my $o = CCC->new;
$o->a(3);
my $o2 = CCC2->new;
$o2->a(4);
$o2->simple(5);
$o2->simplexs(6);

AAA->a(7);
AAA2->a(8);

timethese(
    -2,
    {
        ic1xs => sub { AAA->a },
        ic1pp => sub { AAA2->a },
        ic2xs => sub { BBB->a },
        ic2pp => sub { BBB2->a },
        ic3xs => sub { CCC->a },
        ic3pp => sub { CCC2->a },
        io_xs => sub { $o->a },
        io_pp => sub { $o2->a },
        so_xs => sub { $o2->simplexs },
        so_pp => sub { $o2->simple },
    }
);

BEGIN {

    package IaInstaller;
    use Sub::Name ();
    use Class::Accessor::Inherited::XS;

    {
        no strict 'refs';
        no warnings 'redefine';

        sub mk_inherited_accessors {
            my ( $self, @fields ) = @_;
            my $class = ref $self || $self;
            foreach my $field (@fields) {
                my $name = $field;
                ( $name, $field ) = @$field if ref $field;
                my $full_name = "${class}::$name";
                my $accessor = $self->make_inherited_accessor($field);
                *$full_name = Sub::Name::subname( $full_name, $accessor );
            }
            return;
        }
    }

    sub make_inherited_accessor {
        my ( $class, $field ) = @_;
        return eval "sub { Class::Accessor::Inherited::XS::inherited_accessor(shift, '$field', \@_); }";
    }

    package AAA;
    use base qw/IaInstaller/;
    use strict;

    sub new { return bless {}, shift }

    AAA->mk_inherited_accessors( inherited => qw/a/ );

    package BBB;
    use base 'AAA';

    package CCC;
    use base 'BBB';

    package AAA2;
    use base qw/Class::Accessor::Grouped/;
    use strict;

    sub new { return bless {}, shift }

    sub simple {
        if ( @_ > 1 ) {
            return $_[0]->{simple} = $_[1];
        }
        else {
            return $_[0]->{simple};
        }
    }

    AAA2->mk_group_accessors( inherited => qw/a/ );

    Class::XSAccessor::newxs_accessor( "AAA2::simplexs", "simplexs", 0 );

    package BBB2;
    use base 'AAA2';

    package CCC2;
    use base 'BBB2';

    1;

}
