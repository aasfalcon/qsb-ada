with Sound.Object;

generic
     type Item is private;

package Sound.Ring_Facet is

   subtype Parent is Object.Instance;
   type Instance (Size : Positive) is new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   Overflow_Error, Underflow_Error : exception;

   overriding
   procedure Initialize (This : in out Instance);

   function Get_Count (This : Instance) return Positive;
   function Get_Loaded (This : Instance) return Natural;
   function Get_Space (This : Instance) return Natural;
   function Is_Empty (This : Instance) return Boolean;
   function Is_Full (This : Instance) return Boolean;
   function Is_Half_Full (This : Instance) return Boolean;

   procedure Clear (This : in out Instance);
   procedure Drop (This : in out Instance);
   procedure Pop (This : in out Instance; Destination : out Item);
   procedure Push (This : in out Instance; Source : Item);

private

   type Ring_Items is array (Positive range <>) of Item;
   type Instance (Size : Positive) is new Parent with
      record
         Count : Positive;
         First, Last : Positive;
         Items : Ring_Items (1 .. Size);
      end record;

end Sound.Ring_Facet;
