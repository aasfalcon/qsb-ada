package Sound.Constants is

   --  Event bus limits
   Input_Bus_Size : constant := 1024;
   Output_Bus_Size : constant := 1024;
   Commands_Bus_Size : constant := 32;
   Signals_Bus_Size : constant := 32;
   Packets_Bus_Size : constant := 256;
   Packet_Max_Count : constant := 256;
   Channels_Max_Count : constant := 32;

   Leveler_Dynamic_Range : constant Float := 60.0; --  dB

end Sound.Constants;
