"use client";
import { useContextSelector } from "use-context-selector";
import { useTranslation } from "react-i18next";
import style from "../list.module.css";
import Apps from "./Apps";
import AppContext from "@/context/app-context";
import { LicenseStatus } from "@/types/feature";

const AppList = () => {
  const { t } = useTranslation();
  const systemFeatures = useContextSelector(
    AppContext,
    (v) => v.systemFeatures
  );

  return (
    <div className="relative flex flex-col overflow-y-auto bg-background-body shrink-0 h-0 grow">
      <Apps />
      {/* Community section removed */}
    </div>
  );
};

export default AppList;
