with Sound.Constants;

package Sound.Events is

   subtype Slot is Natural;
   subtype Tag is Natural;

   type Value_Type is  (Bool, Real, Int, None);
   type Value (The_Type : Value_Type := None) is
      record
         case The_Type is
            when Bool =>
               Bool : Boolean;
            when Real =>
               Real : Float;
            when Int =>
               Int : Integer;
            when None => null;
         end case;
      end record;

   Empty_Value : constant Value := (others => <>);

   subtype Data_Count is Positive range 1 .. Constants.Data_Value_Max_Count;
   type Data_Bool_Elements is array (Data_Count range <>) of Boolean;
   type Data_Real_Elements is array (Data_Count range <>) of Float;
   type Data_Int_Elements is array (Data_Count range <>) of Integer;

   type Data_Value (Count : Natural := 0; The_Type : Value_Type := None) is
      record
         case The_Type is
            when Bool =>
               Bools : Data_Bool_Elements (1 .. Count);
            when Real =>
               Reals : Data_Real_Elements (1 .. Count);
            when Int =>
               Ints : Data_Int_Elements (1 .. Count);
            when None => null;
         end case;
      end record;

   Empty_Data_Value : constant Data_Value := (others => <>);

   type Event_Base is tagged
      record
         Tag : Sound.Events.Tag;
         Slot : Sound.Events.Slot;
      end record;

   type Event is new Event_Base with
      record
         Argument : Value;
      end record;

   type Data_Event is new Event_Base with
      record
         Argument : Data_Value;
      end record;

   package Event_Watcher is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      procedure Watch_Event (This : in out Instance; E : Event) is abstract;
   end Event_Watcher;

   package Data_Analyzer is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      procedure Analyze_Data (This : in out Instance;
                              E : Data_Event) is abstract;
   end Data_Analyzer;

end Sound.Events;
