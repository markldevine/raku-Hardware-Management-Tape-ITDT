unit class Hardware::Tape::Management::ITDT::IEStation:api<1>:auth<Mark Devine (mark@markdevine.com)>;

has $.ImportExportStationAddress    is required;
has $.ImportExportState             is required;
has $.ASCASCQ                       is required;
has $.MediaPresent                  is required;
has $.MediaPlacedbyOperator;
has $.ImportEnabled                 is required;
has $.ExportEnabled                 is required;
has $.RobotAccessAllowed            is required;
has $.SourceElementAddressValid     is required;
has $.SourceElementAddress;
has $.LocationFraColRowAcc;
has $.MediaInverted                 is required;
has $.VolumeTag                     is required;

sub fmtout (Str $attr, Str $value) { say sprintf " %s%s %s", $attr, '.' x (31 - $attr.chars), $value; }

method PrintSummary {
    say "Import/Export Station Address " ~ self.ImportExportStationAddress;
    fmtout('Import/Export State ', self.ImportExportState);
    fmtout('ASC/ASCQ ', self.ASCASCQ);
    fmtout('Media Present ', self.MediaPresent);
    fmtout('Media Placed by Operator', self.MediaPlacedbyOperator) with self.MediaPlacedbyOperator;
    fmtout('Import Enabled ', self.ImportEnabled);
    fmtout('Export Enabled ', self.ExportEnabled);
    fmtout('Robot Access Allowed ', self.RobotAccessAllowed);
    fmtout('Source Element Address Valid ', self.SourceElementAddressValid);
    fmtout('Source Element Address', self.SourceElementAddress) with self.SourceElementAddress;
    fmtout('Location (Fra/Col/Row/Acc)', self.LocationFraColRowAcc) with self.LocationFraColRowAcc;
    fmtout('Media Inverted ', self.MediaInverted);
    fmtout('Volume Tag ', self.VolumeTag);
    print "\n";
}

=finish
