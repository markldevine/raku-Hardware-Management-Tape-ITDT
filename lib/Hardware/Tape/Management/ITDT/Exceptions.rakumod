unit class Hardware::Tape::Management::ITDT::Exceptions:api<1>:auth<Mark Devine (mark@markdevine.com)>;

class X::Hardware::Tape::Management::ITDT::NSF is Exception {
    has $.source;
    method message { "ITDT input source ($!source): No such file!" }
}

class X::Hardware::Tape::Management::ITDT::ParseFail is Exception {
    has $.source;
    method message { "ITDT input source ($!source) failed to parse!" }
}

=finish
