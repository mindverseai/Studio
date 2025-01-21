declare module "@remixicon/react" {
  import type { FC, SVGProps } from "react";

  export interface IconProps extends SVGProps<SVGSVGElement> {
    size?: string | number;
    color?: string;
  }

  export const RiErrorWarningFill: FC<IconProps>;
  // Fügen Sie hier weitere Icons hinzu, wenn sie benötigt werden
}
