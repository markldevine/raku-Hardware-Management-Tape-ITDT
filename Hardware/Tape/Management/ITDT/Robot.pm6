unit class Hardware::Tape::Management::ITDT::Robot;

has $.RobotAddress              is required;
has $.RobotState                is required;
has $.ASCASCQ                   is required;
has $.MediaPresent              is required;
has $.SourceElementAddressValid is required;
has $.LocationFraColRowAcc      is required;
has $.MediaInverted             is required;
has $.VolumeTag                 is required;

sub fmtout (Str $attr, Str $value) { say sprintf " %s%s %s", $attr, '.' x (31 - $attr.chars), $value; }

method PrintSummary {
    say "Robot Address " ~ self.RobotAddress;
    fmtout('Robot State ',                  self.RobotState);
    fmtout('ASC/ASCQ ',                     self.ASCASCQ);
    fmtout('Media Present ',                self.MediaPresent);
    fmtout('Source Element Address Valid ', self.SourceElementAddressValid);
    fmtout('Location (Fra/Col/Row/Acc)',    self.LocationFraColRowAcc);
    fmtout('Media Inverted ',               self.MediaInverted);
    fmtout('Volume Tag ',                   self.VolumeTag);
    print "\n";
}

=finish
