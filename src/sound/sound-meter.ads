with Sound.Buffer;
with Sound.Events;
with Sound.Processor;

package Sound.Meter is
   use Sound, Events;

   subtype Parent is Processor.Instance;
   type Instance is new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   ----------------------------------------------------------------------------
   --    Processor slot    --  Type    | Value description                   --
   ----------------------------------------------------------------------------

   type Packet is
      (
         Peaks             --  Peak values for of channel, once per call
      );

   package Packets is
      new Slot_Enum (Packet, Packet_Slot, Processor.Packets.Tail);

   overriding
   procedure Process (This : Instance;
                      Buf : in out Buffer.Instance);
private

   type Instance is new Parent with null record;

end Sound.Meter;
