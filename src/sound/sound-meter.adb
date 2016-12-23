package body Sound.Meter is

   overriding
   procedure Process (This : Instance;
                      Buf : in out Buffer.Instance) is
      Peaks_Data : Data := (Real, Buf.Channels, Reals => (others => 0.0));
      Current : Float := 0.0;
   begin
      for F in 1 .. Buf.Frames loop
         for C in 1 .. Buf.Channels loop
            Current := abs Float (Buf.Samples (F, C));

            if Peaks_Data.Reals (C) < Current then
               Peaks_Data.Reals (C) := Current;
            end if;
         end loop;
      end loop;

      This.Emit (Packets.Slot (Peaks), Peaks_Data);
   end Process;

end Sound.Meter;
