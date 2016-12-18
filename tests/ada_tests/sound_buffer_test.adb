with AUnit.Assertions; use AUnit.Assertions;

with Common.Wave;

package body Sound_Buffer_Test is

   use Common.Wave;

   procedure Set_Up (This : in out Fixture) is
   begin
      This.Buffer_1.Silence;
      This.Buffer_2.Silence;
      This.Buffer_3.Silence;
      This.Buffer_4.Silence;
   end Set_Up;

   procedure With_Channels_Test (This : in out Fixture) is
      Sample : Buffer.Sample;
   begin
      --  stereo to mono
      Fill (This.Buffer_2, Sine'Access, 1);
      Fill (This.Buffer_2, Square'Access, 2);
      This.Buffer_1 := This.Buffer_2.With_Channels (1);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) / 2.0 + Square (F) / 2.0;
         Assert (This.Buffer_1.Samples (F, 1) = Sample, "Mix to mono fail");
      end loop;

      --  mono to stereo
      Fill (This.Buffer_1, Sine'Access);
      This.Buffer_2 := This.Buffer_1.With_Channels (2);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F);
         Assert (This.Buffer_2.Samples (F, 1) = Sample, "Mix to stereo C1");
         Assert (This.Buffer_2.Samples (F, 2) = Sample, "Mix to stereo C2");
      end loop;

      --  multichannel...
      Fill (This.Buffer_4, Sine'Access, 1);
      Fill (This.Buffer_4, Square'Access, 2);
      Fill (This.Buffer_4, Random'Access, 3);
      Fill (This.Buffer_4, Random'Access, 4);

      --  ...to mono
      This.Buffer_1 := This.Buffer_4.With_Channels (1);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) / 2.0 + Square (F) / 2.0;
         Assert (This.Buffer_1.Samples (F, 1) = Sample,
                 "Mix multichannel to mono fail");
      end loop;

      --  ...to stereo
      This.Buffer_2 := This.Buffer_4.With_Channels (2);

      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_2.Samples (F, 1) = Sine (F),
                 "Mix multichannel to stereo fails on C1");
         Assert (This.Buffer_2.Samples (F, 2) = Square (F),
                 "Mix multichannel to stereo fails on C2");
      end loop;

      --  ...to other multiclannel
      This.Buffer_3 := This.Buffer_4.With_Channels (3);

      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_3.Samples (F, 1) = Sine (F),
                 "Downmix multichannel fails on C1");
         Assert (This.Buffer_3.Samples (F, 2) = Square (F),
                 "Downmix multichannel fails on C2");
         Assert (This.Buffer_3.Samples (F, 3) = This.Buffer_4.Samples (F, 3),
                 "Downmix multichannel fails on C3");
      end loop;

      This.Buffer_4 := This.Buffer_3.With_Channels (4);

      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_4.Samples (F, 1) = Sine (F),
                 "Upmix multichannel fails on C1");
         Assert (This.Buffer_4.Samples (F, 2) = Square (F),
                 "Upmix multichannel fails on C2");
         Assert (This.Buffer_4.Samples (F, 3) = This.Buffer_3.Samples (F, 3),
                 "Upmix multichannel fails on C3");
         Assert (This.Buffer_4.Samples (F, 4) = Silent,
                 "Upmix multichannel fails on C4");
      end loop;

      --  mono to multichannel
      This.Buffer_3 := This.Buffer_1.With_Channels (3);
      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) / 2.0 + Square (F) / 2.0;
         Assert (This.Buffer_3.Samples (F, 1) = Sample,
                 "Mix mono to multichannel fails on C1");
         Assert (This.Buffer_3.Samples (F, 2) = Sample,
                 "Mix mono to multichannel fails on C2");
         Assert (This.Buffer_3.Samples (F, 3) = 0.0,
                 "Mix mono to multichannel fails on C3");
      end loop;

      --  stereo to multichannel
      This.Buffer_4 := This.Buffer_2.With_Channels (4);
      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_4.Samples (F, 1) = Sine (F),
                 "Mix stereo to multichannel fails on C1");
         Assert (This.Buffer_4.Samples (F, 2) = Square (F),
                 "Mix stereo to multichannel fails on C2");
         Assert (This.Buffer_4.Samples (F, 3) = 0.0,
                 "Mix stereo to multichannel fails on C3");
         Assert (This.Buffer_4.Samples (F, 4) = 0.0,
                 "Mix stereo to multichannel fails on C4");
      end loop;

      --  sampe count
      Assert (This.Buffer_1 = This.Buffer_1.With_Channels (1),
              "Not equal 1 channels");
      Assert (This.Buffer_2 = This.Buffer_2.With_Channels (2),
              "Not equal 2 channels");
      Assert (This.Buffer_3 = This.Buffer_3.With_Channels (3),
              "Not equal 3 channels");
      Assert (This.Buffer_4 = This.Buffer_4.With_Channels (4),
              "Not equal 4 channels");

   end With_Channels_Test;

   procedure Add_Test (This : in out Fixture) is
      Sample : Sound.Buffer.Sample;
   begin
      Fill (This.Buffer_2, Sine'Access);
      Fill (This.Buffer_3, Square'Access);
      This.Buffer_2.Add (This.Buffer_3);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) + Square (F);
         Assert (This.Buffer_2.Samples (F, 1) = Sample and
                 This.Buffer_2.Samples (F, 2) = Sample,
                 "Adding failed, reference" &
                 Buffer.Sample'Image (Sample) & ", value A" &
                 Buffer.Sample'Image (This.Buffer_2.Samples (F, 1)) &
                 ", value B" &
                 Buffer.Sample'Image (This.Buffer_2.Samples (F, 2)));
      end loop;
   end Add_Test;

   procedure Divide_Test (This : in out Fixture) is
      Sample : Sound.Buffer.Sample;
   begin
      --  simple
      Fill (This.Buffer_1, Sine'Access);
      This.Buffer_1.Divide (3);

      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_1.Samples (F, 1) = Sine (F) / 3.0,
                 "Simple divide failed");
      end loop;

      --  complex
      Fill (This.Buffer_1, Sine'Access);
      Fill (This.Buffer_2, Square'Access);
      Fill (This.Buffer_3, Sine'Access);
      Fill (This.Buffer_4, Square'Access);

      This.Buffer_2.Add (This.Buffer_1);
      This.Buffer_2.Add (This.Buffer_3);
      This.Buffer_2.Add (This.Buffer_4);
      This.Buffer_2.Divide (4);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) / 2.0 + Square (F) / 2.0;
         Assert (This.Buffer_2.Samples (F, 1) = Sample and
                 This.Buffer_2.Samples (F, 2) = Sample,
                 "Complex divide failed: reference" &
                 Buffer.Sample'Image (Sample) & ", value A" &
                 Buffer.Sample'Image (This.Buffer_2.Samples (F, 1)) &
                 ", value B" &
                 Buffer.Sample'Image (This.Buffer_2.Samples (F, 2)));
      end loop;

   end Divide_Test;

   procedure Level_Test (This : in out Fixture) is
      Level_Ratio : constant := 0.3367;
      Sample : Buffer.Sample;
   begin
      Fill (This.Buffer_2, Sine'Access);
      This.Buffer_3 := This.Buffer_2.With_Channels (3);
      This.Buffer_3.Level (Level_Ratio);

      for F in 1 .. Buffer_Frames loop
         Sample := Sine (F) * Level_Ratio;
         Assert (This.Buffer_3.Samples (F, 1) = Sample and
                 This.Buffer_3.Samples (F, 2) = Sample,
                 "Level setting failed");
         Assert (This.Buffer_3.Samples (F, 3) = Buffer.Silent,
                 "Silent channel not silent after leveling");
      end loop;
   end Level_Test;

   procedure Silence_Test (This : in out Fixture) is
   begin
      Fill (This.Buffer_1, Sine'Access);
      Fill (This.Buffer_2, Square'Access);
      Fill (This.Buffer_3, Random'Access);
      Fill (This.Buffer_4, Sine'Access);

      This.Buffer_1.Silence;
      This.Buffer_2.Silence;
      This.Buffer_3.Silence;
      This.Buffer_4.Silence;

      for F in 1 .. Buffer_Frames loop
         Assert (This.Buffer_1.Samples (F, 1) = 0.0, "Not zero B1");

         Assert (This.Buffer_2.Samples (F, 1) = 0.0, "Not zero B2C1");
         Assert (This.Buffer_2.Samples (F, 2) = 0.0, "Not zero B2C2");

         Assert (This.Buffer_3.Samples (F, 1) = 0.0, "Not zero B3C1");
         Assert (This.Buffer_3.Samples (F, 2) = 0.0, "Not zero B3C2");
         Assert (This.Buffer_3.Samples (F, 3) = 0.0, "Not zero B3C3");

         Assert (This.Buffer_4.Samples (F, 1) = 0.0, "Not zero B4C1");
         Assert (This.Buffer_4.Samples (F, 2) = 0.0, "Not zero B4C2");
         Assert (This.Buffer_4.Samples (F, 3) = 0.0, "Not zero B4C3");
         Assert (This.Buffer_4.Samples (F, 4) = 0.0, "Not zero B4C4");
      end loop;
   end Silence_Test;

end Sound_Buffer_Test;
