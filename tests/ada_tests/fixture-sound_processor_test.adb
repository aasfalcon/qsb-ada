with Common.Wave;

with Sound.Bus;

package body Fixture.Sound_Processor_Test is

   use Sound.Buffer, Common.Wave;

   overriding
   procedure Process (This : Fixture_Processor;
                      Buf : in out Buffer.Instance) is
   begin
      for F in 1 .. Buf.Frames loop
         for C in 1 .. Buf.Channels loop
            case This.Mode is
               when Cross_Level =>
                  if C mod 2 = 1 then
                     Buf.Samples (F, C) := Buf.Samples (F, C) / Sample (F);
                  else
                     Buf.Samples (F, C) := Buf.Samples (F, C) /
                                           Sample (Buf.Frames - F + 1);
                  end if;

               when Level =>
                  Buf.Samples (F, C) := Buf.Samples (F, C) / 3.0;

               when Cross_Mute =>
                  if F mod 2 = C mod 2 then
                     Buf.Samples (F, C) := 0.0;
                  end if;

               when Square_Wave =>
                  Buf.Samples (F, 1) := Square (F);
            end case;
         end loop;
      end loop;
   end Process;

   overriding
   procedure Set_Up (This : in out Instance) is
   begin
      This.Random.Initialize;

      This.Processor := new Fixture_Processor;
      This.Bus := new Sound.Bus.Instance;
      This.Bus.Add_Supervisor (This'Unchecked_Access);
      This.Processor.Connect (This.Bus);

      This.Bus.Watch;

      This.Received_Parameters.Clear;
      This.Received_Signals.Clear;
      This.Received_Packets.Clear;

      This.Reference.Input.Clear;
      This.Reference.Output.Clear;
      This.Reference.Commands.Clear;
      This.Reference.Signals.Clear;
      This.Reference.Packets.Clear;
   end Set_Up;

end Fixture.Sound_Processor_Test;
