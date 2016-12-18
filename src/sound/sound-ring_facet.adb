package body Sound.Ring_Facet is

   procedure Initialize (This : in out Instance) is
   begin
      This.Count := This.Size - 1;
      This.First := 1;
      This.Last := 1;
   end Initialize;

   function Get_Count (This : Instance)
      return Positive is (This.Count);

   function Get_Loaded (This : Instance)
      return Natural is ((This.Size - This.First + This.Last) mod This.Size);

   function Get_Space (This : Instance)
      return Natural is (This.Count - This.Get_Loaded);

   function Is_Empty (This : Instance)
      return Boolean is (This.Get_Loaded = 0);

   function Is_Full (This : Instance)
      return Boolean is (This.Get_Loaded = This.Count);

   function Is_Half_Full (This : Instance)
      return Boolean is (This.Count / 2 <= This.Get_Loaded
                         and then This.Get_Loaded > 0);

   procedure Clear (This : in out Instance) is
   begin
      This.First := This.Last;
   end Clear;

   procedure Drop (This : in out Instance) is
   begin
      if This.Is_Empty then
         raise Underflow_Error with "Drop from empty ring";
      end if;

      This.First := 1 + This.First mod This.Size;
   end Drop;

   procedure Pop (This : in out Instance; Destination : out Item) is
   begin
      if This.Is_Empty then
         raise Underflow_Error with "Ring buffer underflow";
      end if;

      Destination := This.Items (This.First);
      This.First := 1 + This.First mod This.Size;
   end Pop;

   procedure Push (This : in out Instance; Source : Item) is
   begin
      if This.Is_Full then
         raise Overflow_Error with "Ring buffer overflow";
      end if;

      This.Items (This.Last) := Source;
      This.Last := 1 + This.Last mod This.Size;
   end Push;

end Sound.Ring_Facet;
