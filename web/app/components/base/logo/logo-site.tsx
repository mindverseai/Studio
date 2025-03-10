"use client";
import type { FC } from "react";
import classNames from "@/utils/classnames";
import { useSelector } from "@/app/components/base/theme-provider";

type LogoSiteProps = {
  className?: string;
};

const LogoSite: FC<LogoSiteProps> = ({ className }) => {
  const { theme } = useSelector((s) => {
    return {
      theme: s.theme,
    };
  });

  const src =
    theme === "light" ? "/logo/mind-verse.png" : `/logo/mind-verse.png`;
  return (
    <img
      src={src}
      className={classNames("block w-[22.651px] h-[24.5px]", className)}
      alt="logo"
    />
  );
};

export default LogoSite;
