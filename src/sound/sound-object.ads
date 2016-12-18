with Ada.Finalization; use Ada.Finalization;

package Sound.Object is

   type Instance is abstract new Controlled with null record;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   overriding
   procedure Adjust (This : in out Instance);

end Sound.Object;
