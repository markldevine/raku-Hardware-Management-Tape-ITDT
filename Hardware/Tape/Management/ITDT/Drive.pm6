unit class Hardware::Tape::Management::ITDT::Drive;

has $.DriveAddress              is required;
has $.DriveState                is required;
has $.ASCASCQ                   is required;
has $.MediaPresent              is required;
has $.RobotAccessAllowed        is required;
has $.SourceElementAddressValid is required;
has $.SourceElementAddress;
has $.LocationFraColRowAcc;
has $.MediaInverted             is required;
has $.SameBusasMediumChanger    is required;
has $.SCSIBusAddressValid       is required;
has $.LogicalUnitNumberValid    is required;
has $.VolumeTag                 is required;

sub fmtout (Str $attr, Str $value) { say sprintf " %s%s %s", $attr, '.' x (31 - $attr.chars), $value; }

method PrintSummary {
    say "Drive Address " ~ self.DriveAddress;
    fmtout('Drive State ',                  self.DriveState);
    fmtout('ASC/ASCQ ',                     self.ASCASCQ);
    fmtout('Media Present ',                self.MediaPresent);
    fmtout('Robot Access Allowed ',         self.RobotAccessAllowed);
    fmtout('Source Element Address Valid ', self.SourceElementAddressValid);
    fmtout('Source Element Address',        self.SourceElementAddress) with self.SourceElementAddress;
    fmtout('Location (Fra/Col/Row/Acc)',    self.LocationFraColRowAcc) with self.LocationFraColRowAcc;
    fmtout('Media Inverted ',               self.MediaInverted);
    fmtout('Same Bus as Medium Changer ',   self.SameBusasMediumChanger);
    fmtout('SCSI Bus Address Valid',        self.SCSIBusAddressValid);
    fmtout('Logical Unit Number Valid',     self.LogicalUnitNumberValid);
    fmtout('Volume Tag ',                   self.VolumeTag);
    print "\n";
}

=finish
