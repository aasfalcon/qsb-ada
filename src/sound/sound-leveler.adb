with Sound.Math;

package body Sound.Leveler is
   overriding
   function Get (This : Instance; Parameter : Parameter_Slot) return Value is
   begin
      case Parameters.Enum (Parameter) is
         when Level =>
            return (Real, This.Level);
      end case;

   exception
      when Constraint_Error =>
         return Parent (This).Get (Parameter);
   end Get;

   overriding
   procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                  Argument : Value) is
   begin
      case Parameters.Enum (Parameter) is
         when Level =>
            This.Level := (if Argument.Real < 0.0 then 0.0 else Argument.Real);
            This.Log_Level := Math.Logarithmic_Level (This.Level);
      end case;

   exception
      when Constraint_Error =>
         Parent (This).Set (Parameter, Argument);
   end Set;

   overriding
   procedure Process (This : Instance; Buf : in out Buffer.Instance) is
      Divisor : Buffer.Sample;
   begin
      if This.Log_Level = 0.0 then
         Buf.Silence;
      elsif This.Log_Level /= 1.0 then
         Divisor := Buffer.Sample (1.0 / This.Log_Level);

         for F in 1 .. Buf.Frames loop
            for C in 1 .. Buf.Channels loop
               Buf.Samples (F, C) := Buf.Samples (F, C) / Divisor;
            end loop;
         end loop;
      end if;
   end Process;

end Sound.Leveler;
