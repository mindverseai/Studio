declare module "ahooks" {
  export function useBoolean(defaultValue?: boolean): [
    boolean,
    {
      setTrue: () => void;
      setFalse: () => void;
      toggle: () => void;
    }
  ];

  export function useClickAway(
    onClickAway: (event: MouseEvent | TouchEvent) => void,
    target: React.RefObject<HTMLElement> | React.RefObject<HTMLElement>[],
    eventName?: string | string[]
  ): void;
}
