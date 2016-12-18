with Ada.Command_Line;

with AUnit.Run, AUnit.Reporter.Text;
with Test_Suite;

use AUnit; --  for AUnit.Failure "=" operator

procedure Ada_Tests is
   function Run is new AUnit.Run.Test_Runner_With_Status (Test_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Reporter.Set_Use_ANSI_Colors (True);

   if Run (Reporter) = Failure then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Ada_Tests;
