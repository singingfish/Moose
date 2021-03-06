package Moose::Meta::TypeCoercion::Union;
our $VERSION = '2.1404';

use strict;
use warnings;
use metaclass;

use Scalar::Util 'blessed';

use parent 'Moose::Meta::TypeCoercion';

use Moose::Util 'throw_exception';

sub compile_type_coercion {
    my $self            = shift;
    my $type_constraint = $self->type_constraint;

    (blessed $type_constraint && $type_constraint->isa('Moose::Meta::TypeConstraint::Union'))
     || throw_exception( NeedsTypeConstraintUnionForTypeCoercionUnion => type_coercion_union_object => $self,
                                                                         type_name                  => $type_constraint->name
                       );

    $self->_compiled_type_coercion(
        sub {
            my $value = shift;

            foreach my $type ( grep { $_->has_coercion }
                @{ $type_constraint->type_constraints } ) {
                my $temp = $type->coerce($value);
                return $temp if $type_constraint->check($temp);
            }

            return $value;
        }
    );
}

sub has_coercion_for_type { 0 }

sub add_type_coercions {
    my $self = shift;
    throw_exception( CannotAddAdditionalTypeCoercionsToUnion => type_coercion_union_object => $self );
}

1;

# ABSTRACT: The Moose Type Coercion metaclass for Unions

__END__

=pod

=head1 DESCRIPTION

This is a subclass of L<Moose::Meta::TypeCoercion> that is used for
L<Moose::Meta::TypeConstraint::Union> objects.

=head1 METHODS

=over 4

=item B<< $coercion->has_coercion_for_type >>

This method always returns false.

=item B<< $coercion->add_type_coercions >>

This method always throws an error. You cannot add coercions to a
union type coercion.

=item B<< $coercion->coerce($value) >>

This method will coerce by trying the coercions for each type in the
union.

=back

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=cut
