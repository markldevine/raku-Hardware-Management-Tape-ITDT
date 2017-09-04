unit class Hardware::Tape::Management::ITDT::Slot;

has $.SlotAddress               is required;
has $.SlotState                 is required;
has $.ASCASCQ                   is required;
has $.MediaPresent              is required;
has $.RobotAccessAllowed        is required;
has $.SourceElementAddressValid is required;
has $.LocationFraColRowAcc      is required;
has $.MediaInverted             is required;
has $.VolumeTag                 is required;

sub fmtout (Str $attr, Str $value) { say sprintf " %s%s %s", $attr, '.' x (31 - $attr.chars), $value; }

method PrintSummary {
    say "Slot Address " ~ self.SlotAddress;
    fmtout('Slot State ', self.SlotState);
    fmtout('ASC/ASCQ ', self.ASCASCQ);
    fmtout('Media Present ', self.MediaPresent);
    fmtout('Robot Access Allowed ', self.RobotAccessAllowed);
    fmtout('Source Element Address Valid ', self.SourceElementAddressValid);
    fmtout('Location (Fra/Col/Row/Acc)', self.LocationFraColRowAcc);
    fmtout('Media Inverted ', self.MediaInverted);
    fmtout('Volume Tag ', self.VolumeTag);
    print "\n";
}

=finish
