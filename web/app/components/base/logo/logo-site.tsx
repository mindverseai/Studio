"use client";
import type { FC } from "react";
import classNames from "@/utils/classnames";

type LogoSiteProps = {
  className?: string;
};

const LogoSite: FC<LogoSiteProps> = ({ className }) => {
  const src = "/logo.png";
  return (
    <img
      src={src}
      className={classNames("block w-[22.651px] h-[24.5px]", className)}
      alt="logo"
    />
  );
};

export default LogoSite;
