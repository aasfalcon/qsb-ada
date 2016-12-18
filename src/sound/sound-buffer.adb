package body Sound.Buffer is

   function With_Channels (This : Instance;
                           Channels : Channel_Count) return Instance is
      Frames : constant Frame_Count := This.Frames;
      Sample : Buffer.Sample;
      Result : Instance (Frames, Channels);
   begin
      if Channels = This.Channels then
         --  no modification
         Result := This;

      elsif Channels = 1 and This.Channels >= 2 then
         --  from stereo+ to mono
         for F in 1 .. Frames loop
            Result.Samples (F, 1) :=
               (This.Samples (F, 1) + This.Samples (F, 2)) / 2.0;
         end loop;

      elsif Channels = 2 and This.Channels = 1 then
         --  from mono to stereo+
         for F in 1 .. Frames loop
            Sample := This.Samples (F, 1);
            Result.Samples (F, 1) := Sample;
            Result.Samples (F, 2) := Sample;
         end loop;

      elsif Channels > 2 and This.Channels = 1 then
         --  from mono to multichannel
         for F in 1 .. Frames loop
            Sample := This.Samples (F, 1);
            Result.Samples (F, 1) := Sample;
            Result.Samples (F, 2) := Sample;

            for C in 3 .. Channels loop
               Result.Samples (F, C) := Silent;
            end loop;
         end loop;

      elsif Channels > This.Channels then
         --  copy all, silence extra
         for F in 1 .. Frames loop
            for C in 1 .. This.Channels loop
               Result.Samples (F, C) := This.Samples (F, C);
            end loop;

            for C in This.Channels + 1 .. Channels loop
               Result.Samples (F, C) := Silent;
            end loop;
         end loop;
      else
         --  copy some first
         for F in 1 .. Frames loop
            for C in 1 .. Channels loop
               Result.Samples (F, C) := This.Samples (F, C);
            end loop;
         end loop;
      end if;

      return Result;
   end With_Channels;

   procedure Add (This : in out Instance; That : Instance) is
   begin
      if This.Frames /= That.Frames then
         raise Constraint_Error with "Different frame count on buffer sum";
      end if;

      if This.Channels /= That.Channels then
         This.Add (That.With_Channels (This.Channels));
      else
         for F in 1 .. This.Frames loop
            for C in 1 .. This.Channels loop
               This.Samples (F, C) :=
                  This.Samples (F, C) + That.Samples (F, C);
            end loop;
         end loop;
      end if;
   end Add;

   procedure Divide (This : in out Instance; Divisor : Positive) is
      Sample_Divisor : constant Sample := Sample (Divisor);
   begin
      for F in 1 .. This.Frames loop
         for C in 1 .. This.Channels loop
            This.Samples (F, C) := This.Samples (F, C) / Sample_Divisor;
         end loop;
      end loop;
   end Divide;

   procedure Level (This : in out Instance; Level : Float) is
      Sample_Level : constant Sample := Sample (Level);
   begin
      for F in 1 .. This.Frames loop
         for C in 1 .. This.Channels loop
            This.Samples (F, C) := This.Samples (F, C) * Sample_Level;
         end loop;
      end loop;
   end Level;

   procedure Silence (This : in out Instance) is
   begin
      This.Samples := (others => (others => Silent));
   end Silence;

end Sound.Buffer;
