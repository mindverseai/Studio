"use client";
import type { FC } from "react";
import React, { useCallback, useState } from "react";
import { useTranslation } from "react-i18next";
import useAvailableVarList from "../../../../_base/hooks/use-available-var-list";
import cn from "@/utils/classnames";
import RemoveButton from "@/app/components/workflow/nodes/_base/components/remove-button";
import Input from "@/app/components/workflow/nodes/_base/components/input-support-select-var";
import type { Var } from "@/app/components/workflow/types";
import { VarType } from "@/app/components/workflow/types";
type Props = {
  className?: string;
  instanceId?: string;
  nodeId: string;
  value: string;
  onChange: (newValue: string) => void;
  hasRemove: boolean;
  onRemove?: () => void;
  placeholder?: string;
  readOnly?: boolean;
  isSupportFile?: boolean;
  insertVarTipToLeft?: boolean;
};

const InputItem: FC<Props> = ({
  className,
  instanceId,
  nodeId,
  value,
  onChange,
  hasRemove,
  onRemove,
  placeholder,
  readOnly,
  isSupportFile,
  insertVarTipToLeft
}) => {
  const { t } = useTranslation();

  const hasValue = !!value;

  const [isFocus, setIsFocus] = useState(false);
  const { availableVars, availableNodesWithParent } = useAvailableVarList(nodeId, {
    onlyLeafNodeVar: false,
    filterVar: (varPayload: Var) => {
      const supportVarTypes = [VarType.string, VarType.number, VarType.secret];
      if (isSupportFile) {
        supportVarTypes.push(...[VarType.file, VarType.arrayFile]);
      }

      return supportVarTypes.includes(varPayload.type);
    }
  });

  const handleRemove = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      onRemove?.();
    },
    [onRemove]
  );

  return (
    <div className={cn("flex items-center", className)}>
      <Input
        id={`input-${String(nodeId)}-${instanceId || "default"}`}
        name={`input-${String(nodeId)}-${instanceId || "default"}`}
        className="grow"
        value={value || ""}
        onChange={onChange}
        placeholder={placeholder}
        readOnly={readOnly}
        insertVarTipToLeft={insertVarTipToLeft}
      />
      {hasRemove && <RemoveButton onClick={handleRemove} />}
    </div>
  );
};
export default React.memo(InputItem);
